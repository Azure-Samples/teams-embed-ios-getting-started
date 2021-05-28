//----------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
//
// Name: TeamsEmbedSdkManager.swift
//----------------------------------------------------------------

import Foundation
import AzureCommunicationCommon
import MeetingUIClient

public protocol TeamsEmbedSdkManagerDelegate {
    func onTeamsSdkStatusUpdated(status: String)
    func onTeamsSdkInitialized()
    func onTeamsSdkDisposed()
}

class TeamsEmbedSdkManager : NSObject, MeetingUIClientCallDelegate, MeetingUIClientCallIdentityProviderDelegate, MeetingUIClientCallUserEventDelegate {
    
    private var internalTeamsEmbedSdkControllerDelegate: TeamsEmbedSdkManagerDelegate?
    
    public var teamsEmbedSdkControllerDelegate: TeamsEmbedSdkManagerDelegate? {
        didSet {
            self.internalTeamsEmbedSdkControllerDelegate = teamsEmbedSdkControllerDelegate
        }
    }
    
    private var meetingUIClient: MeetingUIClient?
    private var meetingUIClientCall: MeetingUIClientCall?
    private var shouldDispose: Bool = false
    private var acsToken: String?
    
    public init(with token: String) {
        self.acsToken = token
    }
    
    public func joinMeeting() {
        
        initTeamsSdk()
        
        let meetingJoinOptions = MeetingUIClientMeetingJoinOptions(displayName: "John Smith", enablePhotoSharing: true, enableNamePlateOptionsClickDelegate: true)
        let meetingURLString = UserDefaults.standard.string(forKey: "meetingURLKey") ?? "<MEETING_URL>"
        let meetingLocator = MeetingUIClientTeamsMeetingLinkLocator(meetingLink: meetingURLString)
        meetingUIClient?.join(meetingLocator: meetingLocator, joinCallOptions: meetingJoinOptions, completionHandler: { (meetingUIClientCall: MeetingUIClientCall?, error: Error?) in
            if (error != nil) {
                self.internalTeamsEmbedSdkControllerDelegate?.onTeamsSdkStatusUpdated(status: error!.localizedDescription)
                print("Join meeting failed: \(error!)")
            }
            else {
                if (meetingUIClientCall != nil) {
                    self.meetingUIClientCall = meetingUIClientCall
                    self.meetingUIClientCall?.meetingUIClientCallDelegate = self
                    self.meetingUIClientCall?.meetingUIClientCallIdentityProviderDelegate = self
                    self.meetingUIClientCall?.meetingUIClientCallUserEventDelegate = self
                    self.internalTeamsEmbedSdkControllerDelegate?.onTeamsSdkStatusUpdated(status: "Started to join ...")
                } else {
                    self.internalTeamsEmbedSdkControllerDelegate?.onTeamsSdkStatusUpdated(status: "Call didn't initialize")
                }
            }
        })
    }
    
    public func joinGroupCall() {
        
        initTeamsSdk()
        
        let groupJoinOptions = MeetingUIClientGroupCallJoinOptions(displayName: "John Smith", enablePhotoSharing: true, enableNamePlateOptionsClickDelegate: true)
        let groupCallId = UserDefaults.standard.string(forKey: "groupIdKey") ?? "<GROUP_ID>"
        let groupLocator = MeetingUIClientGroupCallLocator(groupId: UUID.init(uuidString: groupCallId)!)
        
        meetingUIClient?.join(meetingLocator: groupLocator, joinCallOptions: groupJoinOptions, completionHandler: { (meetingUIClientCall: MeetingUIClientCall?, error: Error?) in
            if (error != nil) {
                DispatchQueue.main.async {
                    self.internalTeamsEmbedSdkControllerDelegate?.onTeamsSdkStatusUpdated(status: error!.localizedDescription)
                    self.teardownTeamsSdk()
                }
                print("Join meeting failed: \(error!)")
            }
            else {
                if (meetingUIClientCall != nil) {
                    self.meetingUIClientCall = meetingUIClientCall
                    self.meetingUIClientCall?.meetingUIClientCallDelegate = self
                    self.meetingUIClientCall?.meetingUIClientCallIdentityProviderDelegate = self
                    self.meetingUIClientCall?.meetingUIClientCallUserEventDelegate = self
                    self.internalTeamsEmbedSdkControllerDelegate?.onTeamsSdkStatusUpdated(status: "Started to join ...")
                } else {
                    self.internalTeamsEmbedSdkControllerDelegate?.onTeamsSdkStatusUpdated(status: "Call didn't initialize")
                }
            }
        })
    }
    
    public func endMeeting() {
        meetingUIClientCall?.hangUp(completionHandler: { (error: Error?) in
            if (error != nil) {
                print("End meeting failed: \(error!)")
                self.internalTeamsEmbedSdkControllerDelegate?.onTeamsSdkStatusUpdated(status: error!.localizedDescription)
                self.teardownTeamsSdk()
            }
            else {
                self.internalTeamsEmbedSdkControllerDelegate?.onTeamsSdkStatusUpdated(status: "Call ending ...")
                self.shouldDispose = true;
            }
        })
    }
        
    private func teardownTeamsSdk() {
        self.shouldDispose = false
        self.internalTeamsEmbedSdkControllerDelegate?.onTeamsSdkStatusUpdated(status: "Teams SDK stopping ...")
        self.meetingUIClient?.dispose(completionHandler: { (error: Error?) in
            if (error != nil) {
                print("Dispose failed: \(error!)")
                self.internalTeamsEmbedSdkControllerDelegate?.onTeamsSdkStatusUpdated(status: error!.localizedDescription)
            } else {
                self.meetingUIClient = nil
                self.meetingUIClientCall = nil
                self.internalTeamsEmbedSdkControllerDelegate?.onTeamsSdkStatusUpdated(status: "Teams SDK stopped")
                
                self.internalTeamsEmbedSdkControllerDelegate?.onTeamsSdkDisposed()
            }
        })
        
    }
    
    func getIconConfig() -> Dictionary<MeetingUIClientIconType, String> {
        var iconConfig = Dictionary<MeetingUIClientIconType, String>()
        iconConfig.updateValue("mic_off", forKey: MeetingUIClientIconType.MicOff)
        return iconConfig
    }
    
    private func fetchTokenAsync(completionHandler: @escaping TokenRefreshHandler) {
        func getTokenFromServer(completionHandler: @escaping (String) -> Void) {
            completionHandler(self.acsToken!)
        }
        getTokenFromServer { newToken in
            completionHandler(newToken, nil)
        }
    }
    
    private func initTeamsSdk() {
        if (meetingUIClient == nil)
        {
            do {
                self.internalTeamsEmbedSdkControllerDelegate?.onTeamsSdkInitialized()
                let communicationTokenRefreshOptions = CommunicationTokenRefreshOptions(initialToken: acsToken, refreshProactively: true, tokenRefresher: fetchTokenAsync(completionHandler:))
                let credential = try CommunicationTokenCredential(withOptions: communicationTokenRefreshOptions)
                self.internalTeamsEmbedSdkControllerDelegate?.onTeamsSdkStatusUpdated(status: "Teams SDK initilizing ...")
                meetingUIClient = MeetingUIClient(with: credential)
                meetingUIClient?.set(iconConfig: self.getIconConfig())
                self.internalTeamsEmbedSdkControllerDelegate?.onTeamsSdkStatusUpdated(status: "Teams SDK initialized")
            }
            catch {
                print("Failed to create communication token credential")
                self.internalTeamsEmbedSdkControllerDelegate?.onTeamsSdkDisposed()
            }
        }
    }

    
// Delegate methods - MeetingUIClientCallDelegate
    
    func meetingUIClientCall(didUpdateCallState callState: MeetingUIClientCallState) {
        switch callState {
        case .connecting:
            self.internalTeamsEmbedSdkControllerDelegate?.onTeamsSdkStatusUpdated(status: "Connecting")
            print("Call state has changed to 'Connecting'")
        case .connected:
            self.internalTeamsEmbedSdkControllerDelegate?.onTeamsSdkStatusUpdated(status: "Connected")
            print("Call state has changed to 'Connected'")
        case .waitingInLobby:
            self.internalTeamsEmbedSdkControllerDelegate?.onTeamsSdkStatusUpdated(status: "In Lobby")
            print("Call state has changed to 'Waiting in Lobby'")
        case .ended:
            self.internalTeamsEmbedSdkControllerDelegate?.onTeamsSdkStatusUpdated(status: "No active call")
            print("Call state has changed to 'Ended'")
            if (shouldDispose) {
                self.teardownTeamsSdk()
            }
        @unknown default:
            print("Unsupported state")
        }
    }
    
    func meetingUIClientCall(didUpdateRemoteParticipantCount remoteParticipantCount: UInt) {
        print("Remote participant count has changed to: \(remoteParticipantCount)")
    }
        
    func onIsMutedChanged() {
        print("Mute state changed to: \(meetingUIClientCall?.isMuted ?? false)")
    }
    
    func onIsSendingVideoChanged() {
        print("Sending video state changed changed to: \(meetingUIClientCall?.isSendingVideo ?? false)")
    }
    
    func onIsHandRaisedChanged(_ participantIds: [Any]) {
        print("Is hand raised changed to: \(meetingUIClientCall?.isHandRaised ?? false)")
    }

// Delegate methods - MeetingUIClientCallIdentityProviderDelegate
    
    func avatarFor(identifier: CommunicationIdentifier, size: MeetingUIClientAvatarSize, completionHandler: @escaping (UIImage?) -> Void) {
        if let userIdentifier = identifier as? CommunicationUserIdentifier
        {
            if (userIdentifier.identifier.starts(with: "8:teamsvisitor:")) {
                // Anonymous teams user will start with prefix 8:teamsvistor:
                let image = UIImage (named: "avatarPink")
                completionHandler(image!)
            }
            else if (userIdentifier.identifier.starts(with: "8:orgid:")) {
                // OrgID user will start with prefix 8:orgid:
                let image = UIImage (named: "avatarDoctor")
                completionHandler(image!)
            }
            else if (userIdentifier.identifier.starts(with: "8:acs:")) {
                // ACS user will start with prefix 8:acs:
                let image = UIImage (named: "avatarGreen")
                completionHandler(image!)
            } else {
                completionHandler(nil)
            }
        } else {
            completionHandler(nil)
        }
    }
    
    func displayNameFor(identifier: CommunicationIdentifier, completionHandler: @escaping (String?) -> Void) {
        if let userIdentifier = identifier as? CommunicationUserIdentifier
        {
            if (userIdentifier.identifier.starts(with: "8:acs:")) {
                let displayName = "Acs User"
                completionHandler(displayName)
            } else {
                completionHandler(nil)
            }
        } else {
            completionHandler(nil)
        }
    }
    
    func subTitleFor(identifier: CommunicationIdentifier, completionHandler: @escaping (String?) -> Void) {
        if let userIdentifier = identifier as? CommunicationUserIdentifier
        {
            if (userIdentifier.identifier.starts(with: "8:acs:")) {
                let displayName = "ACS Subtitle Example"
                completionHandler(displayName)
            } else {
                completionHandler(nil)
            }
        } else {
            completionHandler(nil)
        }
    }
    
    func roleFor(identifier: CommunicationIdentifier, completionHandler: @escaping (MeetingUIClientUserRole) -> Void) {
        completionHandler(MeetingUIClientUserRole.Attendee)
        
    }

// Delegate methods - MeetingUIClientCallUserEventDelegate
    func onNamePlateOptionsClicked(identifier: CommunicationIdentifier) {
        print("Name plate options clicked")
    }
    
    func onParticipantViewLongPressed(identifier: CommunicationIdentifier) {
        print("Particiapnt view long pressed")
    }
}

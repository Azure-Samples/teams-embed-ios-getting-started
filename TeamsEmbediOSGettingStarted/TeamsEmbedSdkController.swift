//
//  ViewControllerViewModel.swift
//  TeamsEmbediOSGettingStarted
//
//  Created by Raimond Sinivee on 5/27/21.
//

import Foundation
import AzureCommunicationCommon
import MeetingUIClient

class TeamsEmbedSdkController : NSObject, MeetingUIClientCallDelegate, MeetingUIClientCallIdentityProviderDelegate, MeetingUIClientCallUserEventDelegate {
    
    private var meetingUIClient: MeetingUIClient?
    private var meetingUIClientCall: MeetingUIClientCall?
    private var shouldDispose: Bool = false
    private var acsToken: String?
    private var viewController: ViewController
    
    private let meetingURL = ""

    private let groupCallId = UUID.init(uuidString: "")
    
    public init(with token: String, viewController: ViewController) {
        self.acsToken = token
        self.viewController = viewController
    }
    
    public func joinMeeting() {
        
        initTeamsSdk()
        
        let meetingJoinOptions = MeetingUIClientMeetingJoinOptions(displayName: "John Smith", enablePhotoSharing: true, enableNamePlateOptionsClickDelegate: true)
        let meetingLocator = MeetingUIClientTeamsMeetingLinkLocator(meetingLink: self.meetingURL)
        meetingUIClient?.join(meetingLocator: meetingLocator, joinCallOptions: meetingJoinOptions, completionHandler: { (meetingUIClientCall: MeetingUIClientCall?, error: Error?) in
            if (error != nil) {
                self.viewController.statusLabel.text = error?.localizedDescription
                print("Join meeting failed: \(error!)")
            }
            else {
                if (meetingUIClientCall != nil) {
                    self.meetingUIClientCall = meetingUIClientCall
                    self.meetingUIClientCall?.meetingUIClientCallDelegate = self
                    self.meetingUIClientCall?.meetingUIClientCallIdentityProviderDelegate = self
                    self.meetingUIClientCall?.meetingUIClientCallUserEventDelegate = self
                    self.viewController.statusLabel.text = "Started to join ..."
                } else {
                    self.viewController.statusLabel.text = "Call didn't initialize"
                }
            }
        })
    }
    
    public func joinGroupCall() {
        
        initTeamsSdk()
        
        let groupJoinOptions = MeetingUIClientGroupCallJoinOptions(displayName: "John Smith", enablePhotoSharing: true, enableNamePlateOptionsClickDelegate: true)
        guard self.groupCallId != nil else {
            print("Not valid group ID")
            return
        }
        let groupLocator = MeetingUIClientGroupCallLocator(groupId: self.groupCallId!)
        meetingUIClient?.join(meetingLocator: groupLocator, joinCallOptions: groupJoinOptions, completionHandler: { (meetingUIClientCall: MeetingUIClientCall?, error: Error?) in
            if (error != nil) {
                DispatchQueue.main.async {
                    self.viewController.statusLabel.text = error?.localizedDescription
                }
                print("Join meeting failed: \(error!)")
            }
            else {
                if (meetingUIClientCall != nil) {
                    self.meetingUIClientCall = meetingUIClientCall
                    self.meetingUIClientCall?.meetingUIClientCallDelegate = self
                    self.meetingUIClientCall?.meetingUIClientCallIdentityProviderDelegate = self
                    self.meetingUIClientCall?.meetingUIClientCallUserEventDelegate = self
                    self.viewController.statusLabel.text = "Started to join ..."
                } else {
                    self.viewController.statusLabel.text = "Call didn't initialize"
                }
            }
        })
    }
    
    public func endMeeting() {
        meetingUIClientCall?.hangUp(completionHandler: { (error: Error?) in
            if (error != nil) {
                print("End meeting failed: \(error!)")
                self.viewController.statusLabel.text = error?.localizedDescription
                self.teardownTeamsSdk()
            }
            else {
                self.viewController.statusLabel.text = "Call ending ..."
                self.shouldDispose = true;
            }
        })
    }
        
    private func teardownTeamsSdk() {
        self.shouldDispose = false
        self.viewController.statusLabel.text = "Teams SDK stopping ..."
        self.meetingUIClient?.dispose(completionHandler: { (error: Error?) in
            if (error != nil) {
                print("Dispose failed: \(error!)")
                self.viewController.statusLabel.text = error?.localizedDescription
            } else {
                self.meetingUIClient = nil
                self.meetingUIClientCall = nil
                self.viewController.statusLabel.text = "Teams SDK stopped"
                
                self.viewController.enableAcsButtons()
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
                self.viewController.disableAcsButtons()
                let communicationTokenRefreshOptions = CommunicationTokenRefreshOptions(initialToken: acsToken, refreshProactively: true, tokenRefresher: fetchTokenAsync(completionHandler:))
                let credential = try CommunicationTokenCredential(withOptions: communicationTokenRefreshOptions)
                self.viewController.statusLabel.text = "Teams SDK initilizing ..."
                meetingUIClient = MeetingUIClient(with: credential)
                meetingUIClient?.set(iconConfig: self.getIconConfig())
                self.viewController.statusLabel.text = "Teams SDK initialized"
            }
            catch {
                print("Failed to create communication token credential")
                self.viewController.enableAcsButtons()
            }
        }
    }

    
// Delegate methods - MeetingUIClientCallDelegate
    
    func meetingUIClientCall(didUpdateCallState callState: MeetingUIClientCallState) {
        switch callState {
        case .connecting:
            self.viewController.statusLabel.text = "Connecting"
            print("Call state has changed to 'Connecting'")
        case .connected:
            self.viewController.statusLabel .text = "Connected"
            print("Call state has changed to 'Connected'")
        case .waitingInLobby:
            self.viewController.statusLabel .text = "In Lobby"
            print("Call state has changed to 'Waiting in Lobby'")
        case .ended:
            self.viewController.statusLabel .text = "No active call"
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

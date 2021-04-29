//----------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
//
// Name: ViewController.swift
//----------------------------------------------------------------

import UIKit
import AzureCommunication
import MeetingUIClient

class ViewController: UIViewController, MeetingUIClientDelegate, MeetingUIClientIdentityProviderDelegate, MeetingUIClientUserEventDelegate {

    private let acsToken = "<ACS_TOKEN>"
    private let meetingURL = "<MEETING_URL>"

    private let groupCallId = UUID.init(uuidString: "<GROUP_ID>")
    
    private var meetingUIClient: MeetingUIClient?
    
    let statusLabel = UILabel(frame: CGRect(x: 100, y: 100, width: 200, height: 50))
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let joinMeetingButton = Button(text: "Join Meeting")
        joinMeetingButton.addTarget(self, action: #selector(joinMeetingTapped), for: .touchUpInside)
        
        joinMeetingButton.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(joinMeetingButton)
        joinMeetingButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        joinMeetingButton.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true

        statusLabel.textColor = .systemBlue
        statusLabel.text = "No active call"
        
        statusLabel.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(statusLabel)
        statusLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        statusLabel.bottomAnchor.constraint(equalTo: joinMeetingButton.topAnchor, constant: -100).isActive = true
        
        let joinGroupCallButton = Button(text: "Join Group Call")
        joinGroupCallButton.addTarget(self, action: #selector(joinGroupCallTapped), for: .touchUpInside)
        
        joinGroupCallButton.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(joinGroupCallButton)
        joinGroupCallButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        joinGroupCallButton.topAnchor.constraint(equalTo: joinMeetingButton.bottomAnchor, constant: 50).isActive = true
        
        let endMeetingButton = Button(text: "End Meeting")
        endMeetingButton.addTarget(self, action: #selector(endMeetingTapped), for: .touchUpInside)
        
        endMeetingButton.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(endMeetingButton)
        endMeetingButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        endMeetingButton.topAnchor.constraint(equalTo: joinGroupCallButton.bottomAnchor, constant: 50).isActive = true
        
        do {
            let communicationTokenRefreshOptions = CommunicationTokenRefreshOptions(initialToken: acsToken, refreshProactively: true, tokenRefresher: fetchTokenAsync(completionHandler:))
            let credential = try CommunicationTokenCredential(withOptions: communicationTokenRefreshOptions)
            meetingUIClient = MeetingUIClient(with: credential)
            meetingUIClient?.meetingUIClientDelegate = self
            meetingUIClient?.set(iconConfig: self.getIconConfig())
        }
        catch {
            print("Failed to create communication token credential")
        }
    }

    func getIconConfig() -> Dictionary<MeetingUIClientIconType, String> {
        var iconConfig = Dictionary<MeetingUIClientIconType, String>()
        iconConfig.updateValue("mic_off", forKey: MeetingUIClientIconType.MicOff)
        return iconConfig
    }
    
    @IBAction func joinMeetingTapped(_ sender: UIButton) {
        joinMeeting()
    }
    
    @IBAction func joinGroupCallTapped(_ sender: UIButton) {
        joinGroupCall()
    }
    
    @IBAction func endMeetingTapped(_ sender: UIButton) {
        endMeeting()
    }
    
    private func fetchTokenAsync(completionHandler: @escaping TokenRefreshHandler) {
        func getTokenFromServer(completionHandler: @escaping (String) -> Void) {
            completionHandler(self.acsToken)
        }
        getTokenFromServer { newToken in
            completionHandler(newToken, nil)
        }
    }
    
    private func joinMeeting() {
        meetingUIClient?.meetingUIClientIdentityProviderDelegate = self
        meetingUIClient?.meetingUIClientUserEventDelegate = self
        let meetingJoinOptions = MeetingUIClientMeetingJoinOptions(displayName: "John Smith", enablePhotoSharing: true, enableNamePlateOptionsClickDelegate: true)
        let meetingLocator = MeetingUIClientTeamsMeetingLinkLocator(meetingLink: self.meetingURL)
        meetingUIClient?.join(meetingLocator: meetingLocator, joinCallOptions: meetingJoinOptions, completionHandler: { (error: Error?) in
            if (error != nil) {
                print("Join meeting failed: \(error!)")
            }
            else {
                self.statusLabel.text = "Started to join ..."
            }
        })
    }
    
    private func joinGroupCall() {
        meetingUIClient?.meetingUIClientIdentityProviderDelegate = self
        meetingUIClient?.meetingUIClientUserEventDelegate = self
        let groupJoinOptions = MeetingUIClientGroupCallJoinOptions(displayName: "John Smith", enablePhotoSharing: true, enableNamePlateOptionsClickDelegate: true, shouldEnablePreJoinView: true)
        guard self.groupCallId != nil else {
            print("Not valid group ID")
            return
        }
        let groupLocator = MeetingUIClientGroupCallLocator(groupId: self.groupCallId!)
        meetingUIClient?.join(meetingLocator: groupLocator, joinCallOptions: groupJoinOptions, completionHandler: { (error: Error?) in
            if (error != nil) {
                print("Join meeting failed: \(error!)")
            }
            else {
                self.statusLabel.text = "Started to join ..."
            }
        })
    }
    
    private func endMeeting() {
        meetingUIClient?.endMeeting(completionHandler: { (error: Error?) in
            if (error != nil) {
                print("End meeting failed: \(error!)")
            }
            else {
                self.statusLabel.text = "Ending call ..."
            }
        })
    }
    
    func meetingUIClient(didUpdateCallState callState: MeetingUIClientCallState) {
        switch callState {
        case .connecting:
            self.statusLabel.text = "Connecting"
            print("Call state has changed to 'Connecting'")
        case .connected:
            self.statusLabel .text = "Connected"
            print("Call state has changed to 'Connected'")
        case .waitingInLobby:
            self.statusLabel .text = "In Lobby"
            print("Call state has changed to 'Waiting in Lobby'")
        case .ended:
            self.statusLabel .text = "No active call"
            print("Call state has changed to 'Ended'")
        @unknown default:
            print("Unsupported state")
        }
    }
    
    func meetingUIClient(didUpdateRemoteParticipantCount remoteParticpantCount: UInt) {
        print("Remote participant count has changed to: \(remoteParticpantCount)")
    }
    
    func avatarFor(userIdentifier: String, completionHandler: @escaping (UIImage?) -> Void) {
        if (userIdentifier.starts(with: "8:teamsvisitor:")) {
            // Anonymous teams user will start with prefix 8:teamsvistor:
            let image = UIImage (named: "avatarPink")
            completionHandler(image!)
        }
        else if (userIdentifier.starts(with: "8:orgid:")) {
            // OrgID user will start with prefix 8:orgid:
            let image = UIImage (named: "avatarDoctor")
            completionHandler(image!)
        }
        else if (userIdentifier.starts(with: "8:acs:")) {
            // ACS user will start with prefix 8:acs:
            let image = UIImage (named: "avatarGreen")
            completionHandler(image!)
        }
        else {
            completionHandler(nil)
        }
    }
    
    func displayNameFor(userIdentifier: String, completionHandler: @escaping (String?) -> Void) {
        if (userIdentifier.starts(with: "8:acs:")) {
            let displayName = "Acs User"
            completionHandler(displayName)
        }
        else {
            completionHandler(nil)
        }
    }
    
    func subTitleFor(userIdentifier: String, completionHandler: @escaping (String?) -> Void) {
        if (userIdentifier.starts(with: "8:acs:")) {
            let displayName = "ACS Subtitle Example"
            completionHandler(displayName)
        }
        else {
            completionHandler(nil)
        }
    }
 
    func onNamePlateOptionsClicked(userIdentifier: String) {
        print("Name plate options clicked")
    }
    
}

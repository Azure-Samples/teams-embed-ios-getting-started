//----------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
//
// Name: ViewController.swift
//----------------------------------------------------------------

import UIKit
import AzureCommunication
import MeetingUIClient

class ViewController: UIViewController, MeetingUIClientDelegate, MeetingUIClientIdentityProviderDelegate, MeetingUIClientUserEventDelegate {

    private let acsToken = "eyJhbGciOiJSUzI1NiIsImtpZCI6IjEwMiIsIng1dCI6IjNNSnZRYzhrWVNLd1hqbEIySmx6NTRQVzNBYyIsInR5cCI6IkpXVCJ9.eyJza3lwZWlkIjoiYWNzOjcxZWM1OTBiLWNiYWQtNDkwYy05OWM1LWI1NzhiZGFjZGU1NF8wMDAwMDAwOS02ZGNiLWEzODItNzFiZi1hNDNhMGQwMDg5NzEiLCJzY3AiOjE3OTIsImNzaSI6IjE2MTgzNjIzNjciLCJpYXQiOjE2MTgzNjIzNjcsImV4cCI6MTYxODQ0ODc2NywiYWNzU2NvcGUiOiJ2b2lwIiwicmVzb3VyY2VJZCI6IjcxZWM1OTBiLWNiYWQtNDkwYy05OWM1LWI1NzhiZGFjZGU1NCJ9.JERIaPtCEnxgcQyb0pgOKBSeGqecQhx6cr3yS1XTMW64ak9Iq4KoIVclOWijY_RAhTcojhgC-ZwoSsHjBqxL1l30r3H-zJQIQ4Mf4fqCV8JI5RpGzbo5Kx1NnwU9Axq_XpGYAjRlASr8UuwRehzGwOUZOzdHkEKwwJf_F4CXx3zeWyI1TR6fyXhFj-JFCo62TO0ARjcx1rROlToSDoqSA3C_ezYlcuZir5UXzMLAfeSZXxVSTeG7O_wQLikke5XEgfJzD-hKh1XqN_zZwXDFJn0L9gM1FJUW3sUGATKQ9P5RXNmg8eQx5gd0D-EDBigB5FuII9p9Wa7j3FlBnTQ6hg"
    private let meetingURL = "https://teams.microsoft.com/l/meetup-join/19%3ameeting_M2Y5NTE5ZTktMTBlYy00MjZlLTg5YmEtMmQzNDllMjViZmMx%40thread.v2/0?context=%7b%22Tid%22%3a%2272f988bf-86f1-41af-91ab-2d7cd011db47%22%2c%22Oid%22%3a%22bdedbe9c-2474-4644-b73d-c4945fed53a0%22%7d"

    private let groupCallId = UUID.init(uuidString: "29228d3e-040e-4656-a70e-890ab4e173e7")
    
    private var meetingUIClient: MeetingUIClient?
    
    let statusLabel = UILabel(frame: CGRect(x: 100, y: 100, width: 200, height: 50))
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let joinMeetingButton = UIButton(frame: CGRect(x: 100, y: 100, width: 200, height: 50))
        joinMeetingButton.backgroundColor = .black
        joinMeetingButton.setTitle("Join Meeting", for: .normal)
        joinMeetingButton.layer.cornerRadius = 8.0
        joinMeetingButton.layer.borderWidth = 1.0
        joinMeetingButton.layer.borderColor = UIColor.white.cgColor
        joinMeetingButton.contentEdgeInsets = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        joinMeetingButton.addTarget(self, action: #selector(joinMeetingTapped), for: .touchUpInside)
        
        joinMeetingButton.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(joinMeetingButton)
        joinMeetingButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        joinMeetingButton.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true

        statusLabel.backgroundColor = .black
        statusLabel.textColor = .systemBlue
        statusLabel.text = "No active call"
        
        statusLabel.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(statusLabel)
        statusLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        statusLabel.bottomAnchor.constraint(equalTo: joinMeetingButton.topAnchor, constant: -100).isActive = true
        
        let joinGroupCallButton = UIButton(frame: CGRect(x: 100, y: 100, width: 200, height: 50))
        joinGroupCallButton.backgroundColor = .black
        joinGroupCallButton.setTitle("Join group call", for: .normal)
        joinGroupCallButton.layer.cornerRadius = 8.0
        joinGroupCallButton.layer.borderWidth = 1.0
        joinGroupCallButton.layer.borderColor = UIColor.white.cgColor
        joinGroupCallButton.contentEdgeInsets = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        joinGroupCallButton.addTarget(self, action: #selector(joinGroupCallTapped), for: .touchUpInside)
        
        joinGroupCallButton.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(joinGroupCallButton)
        joinGroupCallButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        joinGroupCallButton.topAnchor.constraint(equalTo: joinMeetingButton.bottomAnchor, constant: 50).isActive = true
        
        let endMeetingButton = UIButton(frame: CGRect(x: 100, y: 100, width: 200, height: 50))
        endMeetingButton.backgroundColor = .black
        endMeetingButton.setTitle("End meeting", for: .normal)
        endMeetingButton.layer.cornerRadius = 8.0
        endMeetingButton.layer.borderWidth = 1.0
        endMeetingButton.layer.borderColor = UIColor.white.cgColor
        endMeetingButton.contentEdgeInsets = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
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
        }
        catch {
            print("Failed to create communication token credential")
        }
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
        let meetingJoinOptions = MeetingUIClientMeetingJoinOptions(displayName: "John Smith", enablePhotoSharing: false, enableNamePlateOptionsClickDelegate: true)
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
        let groupJoinOptions = MeetingUIClientGroupCallJoinOptions(displayName: "John Smith", shouldEnablePreJoinView: false, enableNamePlateOptionsClickDelegate: true)
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
    }
    
    func subTitleFor(userIdentifier: String, completionHandler: @escaping (String?) -> Void) {
        if (userIdentifier.starts(with: "8:acs:")) {
            let displayName = "ACS Subtitle Example"
            completionHandler(displayName)
        }
    }
 
    func onNamePlateOptionsClicked(userIdentifier: String) {
        print("Name plate options clicked")
    }
    
}

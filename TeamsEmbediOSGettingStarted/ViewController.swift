//----------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
//
// Name: ViewController.swift
//----------------------------------------------------------------

import UIKit
import AzureCommunication
import MeetingUIClient

class ViewController: UIViewController, MeetingUIClientDelegate, MeetingUIClientIdentityProviderDelegate {
  
    private let acsToken = "<ACS_TOKEN>"
    private let meetingURL = "<MEETING_URL>"

    private var meetingUIClient: MeetingUIClient?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        do {
            let communicationTokenRefreshOptions = CommunicationTokenRefreshOptions(initialToken: acsToken, refreshProactively: true, tokenRefresher: fetchTokenAsync(completionHandler:))
            let credential = try CommunicationTokenCredential(with: communicationTokenRefreshOptions)
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
    
    private func fetchTokenAsync(completionHandler: @escaping TokenRefreshOnCompletion) {
        func getTokenFromServer(completionHandler: @escaping (String) -> Void) {
            completionHandler(self.acsToken)
        }
        getTokenFromServer { newToken in
            completionHandler(newToken, nil)
        }
    }
    
    private func joinMeeting() {
        meetingUIClient?.meetingUIClientIdentityProviderDelegate = self
        let meetingJoinOptions = MeetingJoinOptions(displayName: "John Smith", enablePhotoSharing: false)
        meetingUIClient?.join(meetingUrl: meetingURL, meetingJoinOptions: meetingJoinOptions, completionHandler: { (error: Error?) in
            if (error != nil) {
                print("Join meeting failed: \(error!)")
            }
        })
    }
    
    func meetingUIClient(didUpdateCallState callState: CallState) {
        switch callState {
        case .connecting:
            print("Call state has changed to 'Connecting'")
        case .connected:
            print("Call state has changed to 'Connected'")
        case .waitingInLobby:
            print("Call state has changed to 'Waiting in Lobby'")
        case .ended:
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
}

//----------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
//
// Name: ViewController.swift
//----------------------------------------------------------------

import UIKit
import AzureCommunication
import MeetingUIClient
import TeamsAppSDK

class ViewController: UIViewController, MeetingUIClientDelegate, MeetingIdentityProviderDelegate {
  
    private let acsToken = "<ACS_TOKEN>"
    private let meetingURL = "<MEETING_URL>"

    private var meetingClient: MeetingUIClient?
    private var communicationTokenCredential: CommunicationTokenCredential?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        do {
            try communicationTokenCredential = CommunicationTokenCredential(token: acsToken)
            meetingClient = MeetingUIClient(with: communicationTokenCredential!)
            meetingClient?.meetingUIClientDelegate = self
        }
        catch {
            print("Failed to create communication token credential")
        }
    }

    @IBAction func joinMeetingTapped(_ sender: UIButton) {
        joinMeeting()
    }
    
    private func joinMeeting() {
        meetingClient?.meetingIdentityProviderDelegate = self
        let meetingJoinOptions = MeetingJoinOptions(displayName: "John Smith")

        meetingClient?.join(meetingUrl: meetingURL, meetingJoinOptions: meetingJoinOptions, completionHandler: { (error: Error?) in
            if (error != nil) {
                print("Join meeting failed: \(error!)")
            }
        })
    }
    
    func meetingUIClient(_ meetingUIClient: MeetingUIClient, didUpdateCallState callState: CallState) {
        print("Call state has changed to: \(callState)")
    }
    
    func meetingUIClient(_ meetingUIClient: MeetingUIClient, didUpdateRemoteParticipantCount remoteParticpantCount: UInt) {
        print("Remote participant count has changed to: \(remoteParticpantCount)")
    }
    
    func avatarForUserMri(userMri: String, completionHandler completion: @escaping (UIImage?) -> Void) {
        if (userMri .starts(with: "8:teamsvisitor:")) {
            // Anonymous user
            let image = UIImage (named: "avatarPink")
            completion(image!)
        }
        else if (userMri .starts(with: "8:orgid:")) {
            // OrdID user
            let image = UIImage (named: "avatarDoctor")
            completion(image!)
        }
        else if (userMri .starts(with: "8:acs:")) {
            let image = UIImage (named: "avatarGreen")
            completion(image!)
        }
        else {
            completion(nil)
        }
    }
}

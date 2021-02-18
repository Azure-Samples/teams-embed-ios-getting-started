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
  
    private let acsToken = "eyJhbGciOiJSUzI1NiIsImtpZCI6IjEwMiIsIng1dCI6IjNNSnZRYzhrWVNLd1hqbEIySmx6NTRQVzNBYyIsInR5cCI6IkpXVCJ9.eyJza3lwZWlkIjoiYWNzOjA4YjcyZjk0LTc2ZDgtNDFhNS04YTg3LTYxNmU1YjNlY2IyYV8wMDAwMDAwOC01MWVlLTk2N2YtZGVmZC04YjNhMGQwMDQ4MDQiLCJzY3AiOjE3OTIsImNzaSI6IjE2MTM1OTk5MjkiLCJpYXQiOjE2MTM1OTk5MjksImV4cCI6MTYxMzY4NjMyOSwiYWNzU2NvcGUiOiJ2b2lwIiwicmVzb3VyY2VJZCI6IjA4YjcyZjk0LTc2ZDgtNDFhNS04YTg3LTYxNmU1YjNlY2IyYSJ9.cuT1XMJrLiA_ENBC0pcxgjw3DniARDGV4ASVlm0Tbcy1eG4MR6ytyne_GBkQRXlMBg_njWD0zVNosw0DzAct9XI_ErDcu2UOv8_KXID9mHXeHQE6PmU1y0bRf0fdutPjJeyCJ-HeQ2ZGwp27yzgV-pvY0mQFV8YWCzOU438WrUyuUfw01Bft1oIu-qXSeWJeNEhGY41uSy5RkSXvAl2h62IKuNImI6emnQJhrrYuYp2j9NB2_K0mdWhhYwYkW-7mwkFKe8yA16fl-9Bvzyq4B-wuHFSPlqTRh3WHXDpSfjiuNSdlBAkSuQ2C_Mqz_vy2o4g2bdrOn3QRwokjWK2rtg"
    private let meetingURL = "https://teams.microsoft.com/l/meetup-join/19%3ameeting_ZTA1YTBjOTMtNjFmMi00MzZiLThjMGUtMzYxZmUyZTJmOTZk%40thread.v2/0?context=%7b%22Tid%22%3a%2272f988bf-86f1-41af-91ab-2d7cd011db47%22%2c%22Oid%22%3a%226ab9fe04-8ebd-4fe9-a2ed-70c449c924fa%22%7d"

    private var meetingClient: MeetingUIClient?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        do {
            let communicationTokenRefreshOptions = CommunicationTokenRefreshOptions(initialToken: acsToken, refreshProactively: true, tokenRefresher: fetchTokenAsync(completionHandler:))
            let credential = try CommunicationTokenCredential(with: communicationTokenRefreshOptions)
            meetingClient = MeetingUIClient(with: credential)
            meetingClient?.meetingUIClientDelegate = self
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
        meetingClient?.meetingIdentityProviderDelegate = self
        let meetingJoinOptions = MeetingJoinOptions(displayName: "John Smith")

        meetingClient?.join(meetingUrl: meetingURL, meetingJoinOptions: meetingJoinOptions, completionHandler: { (error: Error?) in
            if (error != nil) {
                print("Join meeting failed: \(error!)")
            }
        })
    }
    
    func meetingUIClient(didUpdateCallState callState: CallState) {
        print("Call state has changed to: \(callState)")
    }
    
    func meetingUIClient(didUpdateRemoteParticipantCount remoteParticpantCount: UInt) {
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

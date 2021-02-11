//
//  ViewController.swift
//  MeetingCompositeGettingStarted
//
//  Created by Patrick Latter on 2020-12-14.
//

import UIKit
import AzureCommunication
import MeetingUIClient

class ViewController: UIViewController, MeetingUIClientDelegate, MeetingIdentityProviderDelegate {
  private let acsToken = "eyJhbGciOiJSUzI1NiIsImtpZCI6IjEwMiIsIng1dCI6IjNNSnZRYzhrWVNLd1hqbEIySmx6NTRQVzNBYyIsInR5cCI6IkpXVCJ9.eyJza3lwZWlkIjoiYWNzOjA4YjcyZjk0LTc2ZDgtNDFhNS04YTg3LTYxNmU1YjNlY2IyYV8wMDAwMDAwOC0yOWEzLThhNmItNmEwYi0zNDNhMGQwMDAzMmYiLCJzY3AiOjE3OTIsImNzaSI6IjE2MTI5MjM5MjIiLCJpYXQiOjE2MTI5MjM5MjIsImV4cCI6MTYxMzAxMDMyMiwiYWNzU2NvcGUiOiJ2b2lwIiwicmVzb3VyY2VJZCI6IjA4YjcyZjk0LTc2ZDgtNDFhNS04YTg3LTYxNmU1YjNlY2IyYSJ9.FU6epcsO30aaJw3oEgR8e99A2bNiVtfQGoVqx8t1563Epaz3WeDsZx4DAnICOtA4N0Kn-l5cU_KHB4htVBFM61algp7F_yEjzcWmZjpmteQwAXUJfDzcCq06za9SwxzU27ZhH-g97DgtnWEwAFayYExpFBBWiu9QsenWwhQM1rfbFkOcpJbxUOLDbrNzQQEE1Cq_nuN6xuzO1tRdpIeelKjMeSIaKK5hvnRkU3fmNdeBF2Uw1sQyxR8Bn0tr1aR3fYth0xYYHqqLQSBtEbwhQeXSetnPCP7Tu_g1HkE6r11OW7XFb_Acoh4LRb12m7Vz7aA1HOOUOkl0eSE2OPiJEA"
    
    private let meetingURL = "https://teams.microsoft.com/l/meetup-join/19%3ameeting_OTAxOWZkMjgtYjk5YS00Y2U5LWE2ZTEtNjBkYTNkY2JmZGI0%40thread.v2/0?context=%7b%22Tid%22%3a%2272f988bf-86f1-41af-91ab-2d7cd011db47%22%2c%22Oid%22%3a%226a2237f3-1226-44f7-b215-1092b63bafed%22%7d"

    private var meetingClient: MeetingUIClient?
    private var communicationTokenCredential: CommunicationTokenCredential?
    
    override func viewDidLoad() {
        super.viewDidLoad()
                
        do {
            try communicationTokenCredential = CommunicationTokenCredential(token: acsToken)
            meetingClient = MeetingUIClient(with: communicationTokenCredential!)}
        catch {
            print("Failed to create communication token credential")
        }
    }

    @IBAction func joinMeetingTapped(_ sender: UIButton) {
        joinMeeting()
    }
    
    private func joinMeeting() {
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
    
    func avatarForUserMri( userMri: String, completionHandler completion: @escaping (UIImage?) -> Void) {
        
    }
}

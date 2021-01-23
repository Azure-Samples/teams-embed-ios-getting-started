//
//  ViewController.swift
//  MeetingSDKGettingStarted
//
//  Created by Patrick Latter on 2020-12-14.
//

import UIKit
import AzureCommunication
import MeetingSDK

class ViewController: UIViewController {

    private let acsToken = "eyJhbGciOiJSUzI1NiIsImtpZCI6IjEwMiIsInR5cCI6IkpXVCJ9.eyJza3lwZWlkIjoiYWNzOjA4YjcyZjk0LTc2ZDgtNDFhNS04YTg3LTYxNmU1YjNlY2IyYV8wMDAwMDAwNi1mMzVhLWIwNWEtOGQzMy0zYjNhMGQwMDA0YTUiLCJzY3AiOjE3OTIsImNzaSI6IjE2MDc3MTgyMTAiLCJpYXQiOjE2MDc3MTgyMTAsImV4cCI6MTYwNzgwNDYxMCwiYWNzU2NvcGUiOiJ2b2lwIiwicmVzb3VyY2VJZCI6IjA4YjcyZjk0LTc2ZDgtNDFhNS04YTg3LTYxNmU1YjNlY2IyYSJ9.y-H_DpfVILUVTJlUx9q9hom9sszirBWYp85act6bi1SM-6TY_DUMhK8ncSNFrNgCZn3N_RxvfvrF9hOzwfJuPa4XQIF5viugMmFijCgbAYxFJ29-Mwxf59ALZqSU6HLAIAEZ6iEKoifwXMHc1HIyJE7_zCHCLlhwl5lplAPdbamKF7C_IlPsl2H_Oz9X-CxD8_459bNkCmQZbTHpy1Fx0S4L2edIzVN9d-KtkTaLjPV0wFSKmmV_nqkh-OFCajOosSOQBB_bqBBOmJuAtF8qaA4P23xWY8LGkDYg33ikO0yEOXk03KXnv9_rOWAta-oofNlmTTZiugW_FNsRZPcnxA"
    
    private let meetingURL = "https://teams.microsoft.com/l/meetup-join/19%3ameeting_OTAxOWZkMjgtYjk5YS00Y2U5LWE2ZTEtNjBkYTNkY2JmZGI0%40thread.v2/0?context=%7b%22Tid%22%3a%2272f988bf-86f1-41af-91ab-2d7cd011db47%22%2c%22Oid%22%3a%226a2237f3-1226-44f7-b215-1092b63bafed%22%7d"

    private let joinOptions = JoinOptions(displayName: "John Smith", isMicrophoneMuted: false, isVideoOff: false)
    private var meetingClient: MeetingClient?
    private var communicationTokenCredential: CommunicationTokenCredential?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        do {
            try communicationTokenCredential = CommunicationTokenCredential(token: acsToken)
            meetingClient = MeetingClient(with: communicationTokenCredential!)}
        catch {
            print("Failed to create communication user")
        }
    }

    @IBAction func joinMeetingPressed(_ sender: UIButton) {
        joinMeeting()
    }
    
    private func joinMeeting() {
        meetingClient?.joinMeeting(with: meetingURL, joinOptions: joinOptions, completionHandler: { (error: Error?) in
            if (error != nil) {
                print("Join meeting failed: \(error!)")
            }
        })
    }
}

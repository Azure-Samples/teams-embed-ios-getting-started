//
//  AcsSdkController.swift
//  TeamsEmbediOSGettingStarted
//
//  Created by Raimond Sinivee on 5/27/21.
//

import Foundation
import AVFoundation
import TeamsAppSDK

class AcsSdkController : NSObject {
    
    private var callClient: CallClient?
    private var callAgent: CallAgent?
    private var call: Call?
    
    private var acsToken: String?
    private var viewController: ViewController
    
    public init(with token: String, viewController: ViewController) {
        self.acsToken = token
        self.viewController = viewController
    }
    
    public func joinAcsCall()
    {
        if (self.callClient == nil)
        {
            var userCredential: CommunicationTokenCredential?
            do {
                userCredential = try CommunicationTokenCredential(token: acsToken!)
            } catch {
                print("ERROR: It was not possible to create user credential.")
                self.viewController.statusLabel.text = "Please enter your token in source code"
                return
            }
            
            self.callClient = CallClient()
            
            // Creates the call agent
            self.callClient?.createCallAgent(userCredential: userCredential!) { (agent, error) in
                if error != nil {
                    print("ERROR: It was not possible to create a call agent.")
                    self.viewController.statusLabel.text = "It was not possible to create a call agent"
                    return
                } else {
                    self.callAgent = agent
                    self.viewController.statusLabel.text = "Call agent successfully created."
                    self.startAcsCall()
                }
            }
        }
        else
        {
            startAcsCall()
        }
    }
    
    public func endAcsCall()
    {
        if let call = self.call {
            call.hangUp(options: nil, completionHandler: { (error) in
                if error == nil {
                    self.viewController.statusLabel.text = "Hangup was successfull"
                    self.call = nil
                } else {
                    self.viewController.statusLabel.text = "Hangup failed"
                }
            })
        } else {
            self.viewController.statusLabel.text = "No active call to hanup"
        }
    }
    
    public func stopAcs()
    {
        self.viewController.statusLabel.text = "Disposing ACS"
        self.call?.delegate = nil
        self.call = nil
        self.callAgent?.dispose()
        self.callClient?.dispose()
        self.callAgent = nil
        self.callClient = nil
        self.viewController.statusLabel.text = "Disposed ACS"
    }
    
    private func startAcsCall() {
        AVAudioSession.sharedInstance().requestRecordPermission { (granted) in
            if granted {
                                               
                var callees:[CommunicationIdentifier] = []
                
                callees.append(CommunicationUserIdentifier("8:echo123"))
                
                self.callAgent?.startCall(participants: callees, options: nil) { (call, error) in
                    if (error == nil) {
                        self.call = call
                        self.viewController.statusLabel.text = "Outgoing call placed successfully"
                    } else {
                        print("Failed to get call object")
                        self.viewController.statusLabel.text = "Failed to get call object"
                    }
                }
            }
        }
    }
}

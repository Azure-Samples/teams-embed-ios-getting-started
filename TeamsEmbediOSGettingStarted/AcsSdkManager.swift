//----------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
//
// Name: AcsSdkManager.swift
//----------------------------------------------------------------

import Foundation
import AVFoundation
import TeamsAppSDK

public protocol AcsSdkManagerDelegate {
    func onAcsSdkStatusUpdated(status: String)
    func onAcsSdkInitialized()
    func onAcsSdkDisposed()
}

class AcsSdkManager : NSObject {
    
    private var internalAcsSdkManagerDelegate: AcsSdkManagerDelegate?
    
    public var acsSdkManagerDelegate: AcsSdkManagerDelegate? {
        didSet {
            self.internalAcsSdkManagerDelegate = acsSdkManagerDelegate
        }
    }
    
    private var callClient: CallClient?
    private var callAgent: CallAgent?
    private var call: Call?
    
    private var acsToken: String?
    
    public init(with token: String) {
        self.acsToken = token
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
                self.internalAcsSdkManagerDelegate?.onAcsSdkStatusUpdated(status: "Please enter your token in source code")
                return
            }
            
            self.internalAcsSdkManagerDelegate?.onAcsSdkInitialized()
            self.callClient = CallClient()
            
            // Creates the call agent
            self.callClient?.createCallAgent(userCredential: userCredential!) { (agent, error) in
                if error != nil {
                    print("ERROR: It was not possible to create a call agent.")
                    self.internalAcsSdkManagerDelegate?.onAcsSdkStatusUpdated(status: "It was not possible to create a call agent")
                    self.acsSdkManagerDelegate?.onAcsSdkDisposed()
                    return
                } else {
                    self.callAgent = agent
                    self.internalAcsSdkManagerDelegate?.onAcsSdkStatusUpdated(status: "Call agent successfully created.")
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
                    self.internalAcsSdkManagerDelegate?.onAcsSdkStatusUpdated(status: "Hangup was successfull")
                    self.call = nil
                } else {
                    self.internalAcsSdkManagerDelegate?.onAcsSdkStatusUpdated(status: "Hangup failed")
                }
            })
        } else {
            self.internalAcsSdkManagerDelegate?.onAcsSdkStatusUpdated(status: "No active call to hanup")
        }
    }
    
    public func stopAcs()
    {
        self.internalAcsSdkManagerDelegate?.onAcsSdkStatusUpdated(status: "Disposing ACS")
        self.call?.delegate = nil
        self.call = nil
        self.callAgent?.dispose()
        self.callClient?.dispose()
        self.callAgent = nil
        self.callClient = nil
        self.internalAcsSdkManagerDelegate?.onAcsSdkStatusUpdated(status: "Disposed ACS")
        self.acsSdkManagerDelegate?.onAcsSdkDisposed()
    }
    
    private func startAcsCall() {
        AVAudioSession.sharedInstance().requestRecordPermission { (granted) in
            if granted {
                                               
                var callees:[CommunicationIdentifier] = []
                
                callees.append(CommunicationUserIdentifier("8:echo123"))
                
                self.callAgent?.startCall(participants: callees, options: nil) { (call, error) in
                    if (error == nil) {
                        self.call = call
                        self.internalAcsSdkManagerDelegate?.onAcsSdkStatusUpdated(status: "Outgoing call placed successfully")
                    } else {
                        print("Failed to get call object")
                        self.internalAcsSdkManagerDelegate?.onAcsSdkStatusUpdated(status: "Failed to get call object")
                    }
                }
            }
        }
    }
}

//----------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
//
// Name: ViewController.swift
//----------------------------------------------------------------

import UIKit

class ViewController: UIViewController {

    private let acsToken = "<ACS_TOKEN>"
    
    private var teamsSdkController: TeamsEmbedSdkController?
    private var acsSdkController: AcsSdkController?
    
    public let statusLabel = UILabel(frame: CGRect(x: 100, y: 100, width: 200, height: 50))
    
    let teamsSdkLabel = UILabel(frame: CGRect(x: 100, y: 100, width: 200, height: 50))
    let acsSdkLabel = UILabel(frame: CGRect(x: 100, y: 100, width: 200, height: 50))
    
    let joinMeetingButton = Button(text: "Join Meeting")
    let joinGroupCallButton = Button(text: "Join Group Call")
    let endMeetingButton = Button(text: "Hang up and Stop Teams")
    
    let joinAcsCallButton = Button(text: "Call 8:echo123")
    let endAcsCallButton = Button(text: "End Call")
    let stopAcsCallButton = Button(text: "Stop ACS")
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        statusLabel.textColor = .systemBlue
        statusLabel.text = "SDK not initilized"
        
        statusLabel.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(statusLabel)
        statusLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        statusLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 80).isActive = true
        
        teamsSdkLabel.textColor = .systemPurple
        teamsSdkLabel.text = "----- Teams Embed SDK -----"
        
        teamsSdkLabel.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(teamsSdkLabel)
        teamsSdkLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        teamsSdkLabel.topAnchor.constraint(equalTo: statusLabel.bottomAnchor, constant: 80).isActive = true
        
        joinMeetingButton.addTarget(self, action: #selector(joinMeetingTapped), for: .touchUpInside)
        
        joinMeetingButton.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(joinMeetingButton)
        joinMeetingButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        joinMeetingButton.topAnchor.constraint(equalTo: teamsSdkLabel.bottomAnchor, constant: 10).isActive = true
                        
        joinGroupCallButton.addTarget(self, action: #selector(joinGroupCallTapped), for: .touchUpInside)
        
        joinGroupCallButton.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(joinGroupCallButton)
        joinGroupCallButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        joinGroupCallButton.topAnchor.constraint(equalTo: joinMeetingButton.bottomAnchor, constant: 20).isActive = true

        endMeetingButton.addTarget(self, action: #selector(endMeetingTapped), for: .touchUpInside)
        
        endMeetingButton.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(endMeetingButton)
        endMeetingButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        endMeetingButton.topAnchor.constraint(equalTo: joinGroupCallButton.bottomAnchor, constant: 20).isActive = true
        
        acsSdkLabel.textColor = .systemGreen
        acsSdkLabel.text = "----- ACS Calling SDK -----"
        
        acsSdkLabel.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(acsSdkLabel)
        acsSdkLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        acsSdkLabel.topAnchor.constraint(equalTo: endMeetingButton.bottomAnchor, constant: 50).isActive = true
        
        joinAcsCallButton.addTarget(self, action: #selector(joinAcsCallTapped), for: .touchUpInside)
        
        joinAcsCallButton.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(joinAcsCallButton)
        joinAcsCallButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        joinAcsCallButton.topAnchor.constraint(equalTo: acsSdkLabel.bottomAnchor, constant: 20).isActive = true
               
        endAcsCallButton.addTarget(self, action: #selector(endAcsCallTapped), for: .touchUpInside)
        
        endAcsCallButton.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(endAcsCallButton)
        endAcsCallButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        endAcsCallButton.topAnchor.constraint(equalTo: joinAcsCallButton.bottomAnchor, constant: 20).isActive = true
        
        stopAcsCallButton.addTarget(self, action: #selector(stopAcsCallTapped), for: .touchUpInside)
        
        stopAcsCallButton.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(stopAcsCallButton)
        stopAcsCallButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        stopAcsCallButton.topAnchor.constraint(equalTo: endAcsCallButton.bottomAnchor, constant: 20).isActive = true
        
        self.teamsSdkController = TeamsEmbedSdkController(with: self.acsToken, viewController: self)
        self.acsSdkController = AcsSdkController(with: self.acsToken, viewController: self)
        
    }
    
    @IBAction func joinMeetingTapped(_ sender: UIButton) {
        self.teamsSdkController?.joinMeeting()
    }
    
    @IBAction func joinGroupCallTapped(_ sender: UIButton) {
        self.teamsSdkController?.joinGroupCall()
    }
    
    @IBAction func endMeetingTapped(_ sender: UIButton) {
        self.teamsSdkController?.endMeeting()
    }
    
    @IBAction func joinAcsCallTapped(_ sender: UIButton) {
        self.acsSdkController?.joinAcsCall()
    }
    
    @IBAction func endAcsCallTapped(_ sender: UIButton) {
        self.acsSdkController?.endAcsCall()
    }
    
    @IBAction func stopAcsCallTapped(_ sender: UIButton) {
        self.acsSdkController?.stopAcs()
    }
       
    public func enableAcsButtons() {
        joinAcsCallButton.enable()
        endAcsCallButton.enable()
        stopAcsCallButton.enable()
    }
    
    public func disableAcsButtons() {
        joinAcsCallButton.disable()
        endAcsCallButton.disable()
        stopAcsCallButton.disable()
    }
    
    public func enableTeamsSdkButtons() {
        joinMeetingButton.enable()
        joinGroupCallButton.enable()
        endMeetingButton.enable()
    }
    
    public func disableTeamsSdkButtons() {
        joinMeetingButton.disable()
        joinGroupCallButton.disable()
        endMeetingButton.disable()
    }
}

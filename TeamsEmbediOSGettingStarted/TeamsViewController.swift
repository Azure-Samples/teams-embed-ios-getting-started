//----------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
//
// Name: TeamsViewController.swift
//----------------------------------------------------------------

import Foundation

import UIKit

class TeamsViewController: UIViewController {
    
    private let acsToken = "<ACS_TOKEN>"
    private var teamsSdkController: TeamsEmbedSdkController?
    public let statusLabel = UILabel(frame: CGRect(x: 100, y: 100, width: 200, height: 50))
    let teamsSdkLabel = UILabel(frame: CGRect(x: 100, y: 100, width: 200, height: 50))
    let joinMeetingButton = Button(text: "Join Meeting")
    let joinGroupCallButton = Button(text: "Join Group Call")
    let endMeetingButton = Button(text: "Hang up and Stop Teams")
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
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
        
        self.teamsSdkController = TeamsEmbedSdkController(with: self.acsToken, viewController: self)
    }
    
    @objc func joinMeetingTapped() {
        self.teamsSdkController?.joinMeeting()
    }
    
    @objc func joinGroupCallTapped() {
        self.teamsSdkController?.joinGroupCall()
    }
    
    @objc func endMeetingTapped() {
        self.teamsSdkController?.endMeeting()
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

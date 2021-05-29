//----------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
//
// Name: ViewController.swift
//----------------------------------------------------------------

import UIKit

class ViewController: UIViewController, AcsSdkManagerDelegate {

    private var acsToken = "<ACS_TOKEN>"
    private var acsSdkManager: AcsSdkManager?
    public let statusLabel = UILabel(frame: CGRect(x: 100, y: 100, width: 200, height: 50))
    let joinAcsCallButton = Button(text: "Call 8:echo123")
    let endAcsCallButton = Button(text: "End Call")
    let stopAcsCallButton = Button(text: "Stop ACS")
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let isAcsInit = UserDefaults.standard.bool(forKey: "teamsInitialized")
        isAcsInit ? disableAcsButtons() : enableAcsButtons()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        statusLabel.textColor = .systemBlue
        statusLabel.text = "SDK not initilized"
        
        statusLabel.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(statusLabel)
        statusLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        statusLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 80).isActive = true
        
        joinAcsCallButton.addTarget(self, action: #selector(joinAcsCallTapped), for: .touchUpInside)
        
        joinAcsCallButton.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(joinAcsCallButton)
        joinAcsCallButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        joinAcsCallButton.topAnchor.constraint(equalTo: statusLabel.bottomAnchor, constant: 80).isActive = true
               
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
        
        self.acsToken = UserDefaults.standard.string(forKey: "acsTokenKey") ?? ""
        self.acsSdkManager = AcsSdkManager(with: self.acsToken)
        self.acsSdkManager?.acsSdkManagerDelegate = self
        
    }
    
    @IBAction func joinAcsCallTapped(_ sender: UIButton) {
        self.acsSdkManager?.joinAcsCall()
    }
    
    @IBAction func endAcsCallTapped(_ sender: UIButton) {
        self.acsSdkManager?.endAcsCall()
    }
    
    @IBAction func stopAcsCallTapped(_ sender: UIButton) {
        self.acsSdkManager?.stopAcs()
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

    func onAcsSdkStatusUpdated(status: String) {
        self.statusLabel.text = status
    }
    
    func onAcsSdkInitialized() {
        UserDefaults.standard.setValue(true, forKey: "acsInitialized");
    }
    
    func onAcsSdkDisposed() {
        UserDefaults.standard.setValue(false, forKey: "acsInitialized");
    }
}

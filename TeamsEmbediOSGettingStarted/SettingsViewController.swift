//----------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
//
// Name: SettingsViewController.swift
//----------------------------------------------------------------

import Foundation
import UIKit

class SettingsViewController: UIViewController, UITextFieldDelegate {
    @IBOutlet weak var meetingURLTextField: UITextField!
    @IBOutlet weak var groupIdTextField: UITextField!
    @IBOutlet weak var acsTokenTextField: UITextField!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var showStagingToggle: UISwitch!
    @IBOutlet weak var customizeCallRosterScreenToggle: UISwitch!
    
    @IBAction func showStagingToggled(_ sender: Any) {
        UserDefaults.standard.setValue(showStagingToggle.isOn, forKey: "showStagingKey")
    }
    
    @IBAction func customizeCallRosterScreenToggled(_ sender: Any) {
        UserDefaults.standard.setValue(customizeCallRosterScreenToggle.isOn, forKey: "customizeCallRosterScreenKey")
    }
    
    @IBAction func saveButtonTapped(_ sender: Any) {
        var message: String = ""
        let meetingUrlString = meetingURLTextField.text ?? ""
        
        if meetingUrlString.isEmpty {
            UserDefaults.standard.removeObject(forKey: "meetingURLKey")
            message = message + "Removed meeting url"
        }
        else {
            UserDefaults.standard.setValue(meetingUrlString, forKey: "meetingURLKey")
            message = message + "Saved meeting url"
        }
        
        let groupIdString = groupIdTextField.text ?? ""
        
        if groupIdString.isEmpty {
            UserDefaults.standard.removeObject(forKey: "groupIdKey")
            message = message + " & Removed group id"
        }
        else {
            UserDefaults.standard.setValue(groupIdString, forKey: "groupIdKey")
            message = message + " & Saved group id"
        }
        
        let acsTokenString = acsTokenTextField.text ?? ""
        
        if acsTokenString.isEmpty {
            UserDefaults.standard.removeObject(forKey: "acsTokenKey")
            message = message + " & Removed access token"
        }
        else {
            UserDefaults.standard.setValue(acsTokenString, forKey: "acsTokenKey")
            message = message + " & Saved access token"
        }
        
        throwAlert(message: message)
    }
    
    func throwAlert(message: String) {
        let alert = UIAlertController(title: "Status", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        UIApplication.shared.keyWindow?.rootViewController?.present(alert, animated: true, completion: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureTextFields()
        showStagingToggle.setOn(UserDefaults.standard.bool(forKey: "showStagingKey"), animated: false)
        customizeCallRosterScreenToggle.setOn(UserDefaults.standard.bool(forKey: "customizeCallRosterScreenKey"), animated: false)
        let tapGesture = UITapGestureRecognizer.init(target: self, action: #selector(handleTapGesture))
        view.addGestureRecognizer(tapGesture)
    }
    
    @objc func handleTapGesture() {
        view.endEditing(true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func configureTextFields() {
        meetingURLTextField.placeholder = NSAttributedString.init(string: "Teams Meeting URL", attributes: [NSAttributedString.Key.foregroundColor : UIColor.lightGray]).string
        let meetingUrlString = UserDefaults.standard.string(forKey: "meetingURLKey") ?? ""
        
        if !meetingUrlString.isEmpty {
            meetingURLTextField.text = meetingUrlString
        }
        meetingURLTextField.delegate = self
        
        groupIdTextField.placeholder = NSAttributedString.init(string: "Group Id Guid", attributes: [NSAttributedString.Key.foregroundColor : UIColor.lightGray]).string
        let groupIdString = UserDefaults.standard.string(forKey: "groupIdKey") ?? ""
        
        if !groupIdString.isEmpty {
            groupIdTextField.text = groupIdString
        }
        groupIdTextField.delegate = self
        
        acsTokenTextField.placeholder = NSAttributedString.init(string: "Access Token", attributes: [NSAttributedString.Key.foregroundColor : UIColor.lightGray]).string
        let acsTokenString = UserDefaults.standard.string(forKey: "acsTokenKey") ?? ""
        
        if !acsTokenString.isEmpty {
            acsTokenTextField.text = acsTokenString
        }
        acsTokenTextField.delegate = self
    }
    
}

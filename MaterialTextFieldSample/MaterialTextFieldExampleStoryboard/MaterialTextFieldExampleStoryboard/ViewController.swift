//
//  ViewController.swift
//  MaterialTextFieldExampleStoryboard
//
//  Created by Ankit on 05/05/26.
//

import UIKit
import MTTextField

class ViewController: UIViewController {
    @IBOutlet weak var emailTextField: MaterialTextField!
    
    private var userNameTextFieldController: MTTextInputControllerUnderline?
    private var emailTextFieldController: MTTextInputControllerOutlined?
    
    private let darkTextColor = UIColor.black
    private let placeholderColor = UIColor.blue
    
    override func viewDidLoad() {
        super.viewDidLoad()
        customizeEmailTextField()
    }
    
    private func customizeEmailTextField() {
        emailTextFieldController = MTTextInputControllerOutlined(textInput: emailTextField)
        
        emailTextFieldController?.placeholderText = "Email Address"
        emailTextFieldController?.activeColor = .white
        emailTextFieldController?.normalColor = .white
        emailTextFieldController?.floatingPlaceholderActiveColor = .white
        emailTextFieldController?.floatingPlaceholderNormalColor = .white
        
        emailTextField.textColor = .white
        emailTextField.tintColor = .white
    }
}


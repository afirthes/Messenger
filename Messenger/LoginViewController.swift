//
//  ViewController.swift
//  Messenger
//
//  Created by Afir Thes on 03.01.2022.
//

import UIKit
import Gallery
import ProgressHUD

class LoginViewController: UIViewController {
    
    var login: Bool = true {
        didSet {
            updateUIFor(login)
        }
    }
    
    //Mark: - IBOUtlets
    //labels
    @IBOutlet weak var emailLabelOutlet: UILabel!
    @IBOutlet weak var passwordLabelOutlet: UILabel!
    @IBOutlet weak var repeatPasswordLabel: UILabel!
    @IBOutlet weak var signUpLabel: UILabel!
    
    //textFields
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var repeatPasswordTextField: UITextField!
    
    //Buttons
    @IBOutlet weak var loginButtonOutlet: UIButton!
    @IBOutlet weak var signUpButtonOutlet: UIButton!
    @IBOutlet weak var resendEmailButtonOutlet: UIButton!
    @IBOutlet weak var forgotPasswordButtonOutlet: UIButton!
    
    //Views
    @IBOutlet weak var repeatPasswordLineView: UIView!
    
    //MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        updateUIFor(login)
        setuptextFieldDelegates()
        setupBackgroundTap()
    }
    
    //MARK: - IBActions
    @IBAction func loginButtonPressed(_ sender: Any) {
        if isDataInputedFor(type: login ? "login" : "registration") {
            login ? loginUser() : registerUser()
        } else {
            ProgressHUD.showFailed("All fields are required")
        }
    }
    
    @IBAction func forgotPasswordPressed(_ sender: Any) {
        if isDataInputedFor(type: "password") {
            resetPassword()
        } else {
            ProgressHUD.showFailed("Email is required")
        }
    }
    
    @IBAction func resendEmailPressed(_ sender: Any) {
        if isDataInputedFor(type: "password") {
            resendVerificationEmail()
        } else {
            ProgressHUD.showFailed("Email is required")
        }
    }
    
    @IBAction func signUpPressed(_ sender: UIButton) {
        login.toggle()
    }
    
    //MARK: - Setup
    private func setuptextFieldDelegates() {
        // when user starts typing
        emailTextField.addTarget(self, action: #selector(textFieldDidChanged(_:)), for: .editingChanged)
        passwordTextField.addTarget(self, action: #selector(textFieldDidChanged(_:)), for: .editingChanged)
        repeatPasswordTextField.addTarget(self, action: #selector(textFieldDidChanged(_:)), for: .editingChanged)
    }
    
    @objc func textFieldDidChanged(_ textField: UITextField) {
        updatePlaceholderLabels(textField)
    }
    
    private func setupBackgroundTap() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(backgroundTapped))
        view.addGestureRecognizer(tapGesture)
    }
    
    @objc func backgroundTapped() {
        view.endEditing(false)
    }
    
    //MARK: - Animations
    
    private func updateUIFor(_ login: Bool) {
        
        loginButtonOutlet.setImage(UIImage(named: login ? "loginBtn" : "registerBtn"), for: .normal)
        signUpButtonOutlet.setTitle( login ? "Sign Up" : "Login", for: .normal)
        signUpLabel.text = login ? "Don't have an acount?" : "Have an account?"
        
        repeatPasswordTextField.text = login ? "" : repeatPasswordTextField.text
        //forgotPasswordButtonOutlet.isHidden = !login
        
        UIView.animate(withDuration: 0.5) {
            self.repeatPasswordTextField.isHidden = login
            self.repeatPasswordLabel.isHidden = login
            self.repeatPasswordLineView.isHidden = login
        }
        
    }
    
    private func updatePlaceholderLabels(_ textField: UITextField) {
        switch textField {
        case emailTextField:
            emailLabelOutlet.text = textField.hasText ? "Email" : ""
        case passwordTextField:
            passwordLabelOutlet.text = textField.hasText ? "Password" : ""
        default: //repeatPasswordTextField:
            repeatPasswordLabel.text = textField.hasText ? "Repeat password" : ""
            
        }
    }
    
    //MARK: - Helpers
    private func isDataInputedFor(type: String) -> Bool {
        switch type {
        case "login":
            return emailTextField.text != "" && passwordTextField.text != ""
        case "registration":
            return emailTextField.text != ""
            && passwordTextField.text != ""
            && repeatPasswordTextField.text != ""
        default: // forgotPassword
            return emailTextField.text != ""
        }
    }
    
    private func loginUser() {
        FirebaseUserListener.shared.loginUserWithEmail(email: emailTextField.text!, password: passwordTextField.text!) { error, isEmailVerified in
            
            if error == nil {
                if isEmailVerified {
                    self.goToApp()
                } else {
                    ProgressHUD.showFailed("Please verify email")
                    self.resendEmailButtonOutlet.isHidden = false
                }
            } else {
                ProgressHUD.showFailed(error!.localizedDescription)
            }
        }
    }
    
    private func registerUser() {
        if passwordTextField.text == repeatPasswordTextField.text {
            FirebaseUserListener.shared.registerUserWith(email: emailTextField.text!, password: passwordTextField.text!) { error in
                
                if error == nil {
                    ProgressHUD.showSucceed("Verification email sent.")
                    self.resendEmailButtonOutlet.isHidden = false
                } else {
                    ProgressHUD.showFailed(error!.localizedDescription)
                }
            }
        } else {
            ProgressHUD.showFailed("The passwords dont match")
        }
    }
    
    private func resetPassword() {
        FirebaseUserListener.shared.resetPasswordFor(email: emailTextField.text!) { error in
            if error == nil {
                ProgressHUD.showSuccess("Reset link sent to email.")
            } else {
                ProgressHUD.showFailed(error!.localizedDescription)
            }
        }
    }
    
    private func resendVerificationEmail() {
        FirebaseUserListener.shared.resendVerificationEmail(email: emailTextField.text!) { error in
            if error == nil {
                ProgressHUD.showSuccess("New verification email sent.")
            } else {
                ProgressHUD.showFailed(error!.localizedDescription)
            }
        }
    }
    
    //MARK: - Navigation
    private func goToApp() {
        print("go to app")
        let mainView = UIStoryboard(name:"Main", bundle: nil)
            .instantiateViewController(withIdentifier: "MainApp") as! UITabBarController
        
        mainView.modalPresentationStyle = .fullScreen
        self.present(mainView, animated: true, completion: nil)
        
        
    }
}


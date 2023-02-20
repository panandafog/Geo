//
//  ResetPasswordViewController.swift
//  geo
//
//  Created by Andrey on 07.02.2023.
//

import UIKit

public protocol ResetPasswordViewControllerDelegate: AnyObject {
    func handlePasswordResetCompletion()
}

class ResetPasswordViewController: UIViewController, Storyboarded, NotificatingViewController {
    
    weak var coordinator: ResetPasswordViewControllerDelegate?
    
    private let authorizationService = AuthorizationService.shared
    private var code: Int? {
        Int(codeTextField.text ?? "")
    }
    
    @IBOutlet private var newPasswordTextField: UITextField!
    @IBOutlet private var passwordConfirmationTextField: UITextField!
    @IBOutlet private var codeTextField: UITextField!
    @IBOutlet private var confirmationButton: UIButton!
    
    @IBOutlet private var activityIndicator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Confirm password reset"
        isModalInPresentation = true
    }
    
    @IBAction private func passwordChanged(_ sender: UITextField) {
        verifyCreds()
    }
    @IBAction private func passwordConfirmationChanged(_ sender: UITextField) {
        verifyCreds()
    }
    @IBAction private func codeChanged(_ sender: UITextField) {
        verifyCreds()
    }
    
    @IBAction private func confirmationButtonTouched(_ sender: UIButton) {
        confirmChangingPassword()
    }
    
    private func verifyCreds() {
        confirmationButton.isEnabled = (newPasswordTextField.text?.count ?? 0) >= AuthorizationService.minPasswordLength
        && newPasswordTextField.text == passwordConfirmationTextField.text
        && String(code ?? 0).count == AuthorizationService.confirmationCodeLength
    }
    
    private func confirmChangingPassword() {
        setControls(enabled: false)
        activityIndicator.startAnimating()
        
        guard let newPassword = newPasswordTextField.text,
              let code = code
        else {
            return
        }
        authorizationService.confirmPasswordChange(code: code, newPassword: newPassword) { [weak self] result in
            DispatchQueue.main.async {
                self?.setControls(enabled: true)
                self?.activityIndicator.stopAnimating()
            }
            
            switch result {
            case .success(()):
                self?.authorizationService.signOut()
                self?.coordinator?.handlePasswordResetCompletion()
            case .failure(let error):
                self?.showErrorAlert(error)
            }
        }
    }
    
    private func setControls(enabled: Bool) {
        confirmationButton.isEnabled = enabled
        newPasswordTextField.isEnabled = enabled
        passwordConfirmationTextField.isEnabled = enabled
        codeTextField.isEnabled = enabled
    }
}
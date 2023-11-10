//
//  ViewController.swift
//  SlothParty
//
//  Created by Massimo Maddaluno on 05/05/2020.
//  Copyright © 2020 Massimo Maddaluno. All rights reserved.
//

import UIKit
import CoreLocation
import CloudKit
import AuthenticationServices
import SwiftKeychainWrapper

class LoginVC: UIViewController {

    var appleSignInDelegates: SignInWithAppleDelegates! = nil
    var signInSuccess = false {
        didSet{
            DispatchQueue.main.async {
                self.performSegue(withIdentifier: "loginSegue", sender: self)
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        performExistingAccountSetupFlows()

    }
    

}

extension LoginVC{
    
    func setupView(){
        let appleButton = ASAuthorizationAppleIDButton()
        appleButton.translatesAutoresizingMaskIntoConstraints = false
        appleButton.addTarget(self, action: #selector(didTapAppleButton), for: .touchUpInside)
        view.addSubview(appleButton)
        appleButton.heightAnchor.constraint(equalToConstant: 60).isActive = true
        NSLayoutConstraint.activate([
            appleButton.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            appleButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 30),
            appleButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -30)
        ])
    }
    
    @objc func didTapAppleButton(){
        let provider = ASAuthorizationAppleIDProvider()
        let request = provider.createRequest()
        request.requestedScopes = [.fullName, .email]
        
        performSignIn(using: [request])
    }
    
    private func performExistingAccountSetupFlows() {
      #if !targetEnvironment(simulator)
      // Note that this won't do anything in the simulator.  You need to
      // be on a real device or you'll just get a failure from the call.
      let requests = [
        ASAuthorizationAppleIDProvider().createRequest(),
        ASAuthorizationPasswordProvider().createRequest()
      ]

      performSignIn(using: requests)
      #endif
    }
    
    private func performSignIn(using requests: [ASAuthorizationRequest]) {
     
        appleSignInDelegates = SignInWithAppleDelegates(window: view.window) { success in
            
            if success.signedOk{
                self.signInSuccess = true
                print("Signing operation successfully completed")
                if success.automaticSign{
                    print("Automatic sign in successfully completed")
                }
            }
            else{
                if !success.automaticSign{
                    print("Automatic sign is not available")
                }
                else{
                    print("Error during login")
                    let alert = UIAlertController(title: "Sign in Error", message: "An error occurred while signing in with Apple ID, please try again.", preferredStyle: UIAlertController.Style.alert)
                    
                    alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: nil))
                    
                    self.present(alert, animated: true, completion: nil)
                }
            }
            
            
            
            
      }
        
        let controller = ASAuthorizationController(authorizationRequests: requests)

        controller.delegate = appleSignInDelegates
        controller.presentationContextProvider = appleSignInDelegates

        controller.performRequests()

    }
    
}


//
//  SignInWithAppleDelegates.swift
//  MacroApp
//
//  Created by Massimo Maddaluno on 28/04/2020.
//  Copyright © 2020 Massimo Maddaluno. All rights reserved.
//

import UIKit
import AuthenticationServices
import Contacts
import CloudKit
import SwiftKeychainWrapper

struct Info{
    var signedOk: Bool
    var automaticSign: Bool
}

class SignInWithAppleDelegates: NSObject {
  private let signInSucceeded: (Info) -> Void
  private weak var window: UIWindow!
  
  init(window: UIWindow?, onSignedIn: @escaping (Info) -> Void) {
    self.window = window
    self.signInSucceeded = onSignedIn
  }
}


extension SignInWithAppleDelegates: ASAuthorizationControllerDelegate {
  private func registerNewAccount(credential: ASAuthorizationAppleIDCredential) {
    
    let tempGiven = credential.fullName?.givenName ?? ""
    
    let tempFamily = credential.fullName?.familyName ?? ""
    
    let tempArray : [GroupData] = []

    LoginManager.shared.firstLoginProcedure(ID: credential.user, name: tempGiven, surname: tempFamily, username: "Lo scapocchiatore folle", score: 0, groups: tempArray, avatarID: 0, friendList: []) { (isSuccessful) in
        
        //This is setted to true to automatize the login process for the next login
        JsonManager.shared.saveJson(value: true)
        
        self.signInSucceeded(Info(signedOk: isSuccessful, automaticSign: false))
    }
    

  }

  private func signInWithExistingAccount(credential: ASAuthorizationAppleIDCredential) {
    // You *should* have a fully registered account here.  If you get back an error from your server
    // that the account doesn't exist, you can look in the keychain for the credentials and rerun setup
    
    //This is setted to true to automatize the login process for the next login
    JsonManager.shared.saveJson(value: true)
    
    LoginManager.shared.loginProcedure(ID: credential.user) { (isFinished) in
        self.signInSucceeded(Info(signedOk: isFinished, automaticSign: isFinished))
    }
  }

  private func signInWithUserAndPassword(credential: ASPasswordCredential) {
    // You *should* have a fully registered account here.  If you get back an error from your server
    // that the account doesn't exist, you can look in the keychain for the credentials and rerun setup

    // if (WebAPI.Login(credential.user, credential.password)) {
    //   ...
    // }
    
    self.signInSucceeded(Info(signedOk: true, automaticSign: true))
  }
  
  func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
    
    
    
    switch authorization.credential {

    case let appleIdCredential as ASAuthorizationAppleIDCredential:
        if let _ = appleIdCredential.email, let _ = appleIdCredential.fullName {
        
        registerNewAccount(credential: appleIdCredential)
        
      } else {
        
        signInWithExistingAccount(credential: appleIdCredential)
      }

      break
      
    case let passwordCredential as ASPasswordCredential:
      signInWithUserAndPassword(credential: passwordCredential)

      break
      
    default:
      break
    }
  }
  
  func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
    // Handle error.
    
  }
}

extension SignInWithAppleDelegates: ASAuthorizationControllerPresentationContextProviding {
  func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
    return self.window
    
  }
}

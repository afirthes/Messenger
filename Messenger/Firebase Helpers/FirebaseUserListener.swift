//
//  FirebaseUserListener.swift
//  Messenger
//
//  Created by Afir Thes on 15.01.2022.
//

import Foundation
import Firebase
import UIKit

class FirebaseUserListener {
    
    static let shared = FirebaseUserListener()
    
    private init() {}
    
    //MARK: - Login
    func loginUserWithEmail(email: String, password: String, completion: @escaping (_ error: Error?, _ isEmailVerified: Bool)->Void) {
        
        Auth.auth().signIn(withEmail: email, password: password) { authData, error in
            if error == nil && authData!.user.isEmailVerified {
                FirebaseUserListener.shared.downlaodUserFromFirebse(userId: authData!.user.uid, email: email)
                completion(error, true)
            } else {
                print("email is not verified")
                completion(error, false)
            } 
        }
    }
    
    //MARK: - Register
    func registerUserWith(email: String, password: String, completion: @escaping (_ error: Error?)->Void) {
        
        Auth.auth().createUser(withEmail: email, password: password) { authDataResult, error in
            completion(error)
            if error == nil {
                // sent verification email
                authDataResult!.user.sendEmailVerification { error in
                    print("auth email sent with error: ", error?.localizedDescription ?? "")
                }
                
                // create user and save it
                if let fuser = authDataResult?.user  {
                    let user = User(id: fuser.uid, userName: email, email: email, pushId: "", avatarLink: "", status: "Hey there I'm using Messenger")
                    
                    saveUserLocally(user)
                    self.saveUserToFirestore(user)
                }
            }
        }
    }
    
    //MARK: - Resend link methods
    func resendVerificationEmail(email: String, completion: @escaping (_ error:Error?)->Void) {
        
        Auth.auth().currentUser?.reload(completion: { error in
            Auth.auth().currentUser?.sendEmailVerification(completion: { error in
                completion(error)
            })
        })
    }
    
    func resetPasswordFor(email: String, completion: @escaping (_ error:Error?)->Void) {
        Auth.auth().sendPasswordReset(withEmail: email) { error in
            completion(error)
        }
    }
    
    //MARK: - Save users
    func saveUserToFirestore(_ user: User) {
        
        do {
            try firebaseReference(.User).document(user.id).setData(from: user)
        } catch {
            print(error.localizedDescription, "adding user")
        }
        
    }
    
    func downlaodUserFromFirebse(userId: String, email: String? = nil) {
        firebaseReference(.User).document(userId).getDocument { querySnapshot, error in
            guard let document = querySnapshot else {
                print("no document fro user \(userId)")
                return
            }
            
            let result = Result {
                try? document.data(as: User.self)
            }
            
            switch result {
            case .success(let userObject):
                if let user = userObject {
                    saveUserLocally(user)
                } else {
                    print("Document does not exist")
                }
            case .failure(let error):
                print("Error decoding user", error.localizedDescription)
                
            }
        }
    }
    
}

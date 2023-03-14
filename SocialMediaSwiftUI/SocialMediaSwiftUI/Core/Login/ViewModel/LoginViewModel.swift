//
//  LoginViewModel.swift
//  SocialMediaSwiftUI
//
//  Created by Yasin Erdemli on 14.03.2023.
//

import SwiftUI
import Firebase
import FirebaseFirestoreSwift
import FirebaseFirestore

class LoginViewModel: ObservableObject {
    @Published var email: String = ""
    @Published var password: String = ""
    @Published var createAccount: Bool = false
    @Published var showError: Bool = false
    @Published var errorMessage: String = ""
    @Published var isLoading: Bool = false
    @Published var logStatus: Bool = UserDefaults.standard.bool(forKey: "log_status")
    @Published var userNameStored: String = (UserDefaults.standard.string(forKey: "user_name") ?? "")
    @Published var userUID: String = (UserDefaults.standard.string(forKey: "user_UID") ?? "")
    @Published var userProfileUrl = UserDefaults.standard.url(forKey: "user_profile_url")
    
    func loginUser() {
        isLoading = true
        closeKeyboard()
        Task {
            do {
                try await Auth.auth().signIn(withEmail: email, password: password)
                try await fetchUser()
            } catch {
                await setError(error)
                print(error)
            }
        }
    }
    
    func fetchUser() async throws {
        guard let userID = Auth.auth().currentUser?.uid else { return }
        print(userID)
        let user = try await Firestore.firestore().collection("users").document(userID).getDocument(as: User.self)
        await MainActor.run(body: {
            UserDefaults.standard.set(user.username, forKey: "user_name")
            UserDefaults.standard.set(userUID, forKey: "user_UID")
            UserDefaults.standard.set(user.userProfileURL, forKey: "user_profile_url")
            UserDefaults.standard.set(true,forKey: "log_status")
            logStatus = true
            print(user)
        })
    }
    
    func resetPassword() {
        Task {
            do {
                try await Auth.auth().sendPasswordReset(withEmail: email)
                print("link sent")
            } catch {
                await setError(error)
            }
        }
        
    }
    
    func setError(_ error: Error) async {
        await MainActor.run(body: {
            self.isLoading = false
            errorMessage = error.localizedDescription
            showError.toggle()
        })
    }
    
    func closeKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

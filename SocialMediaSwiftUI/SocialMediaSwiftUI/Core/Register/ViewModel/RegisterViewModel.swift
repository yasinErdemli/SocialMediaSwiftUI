//
//  RegisterViewModel.swift
//  SocialMediaSwiftUI
//
//  Created by Yasin Erdemli on 14.03.2023.
//

import Foundation
import Firebase
import FirebaseFirestore
import FirebaseStorage
import _PhotosUI_SwiftUI

class RegisterViewModel: ObservableObject {
    @Published var email: String = ""
    @Published var password: String = ""
    @Published var username: String = ""
    @Published var userBio: String = ""
    @Published var userBioLink: String = ""
    @Published var userProfilePicData: Data?
    @Published var showImagePicker: Bool = false
    @Published var photoItem: PhotosPickerItem?
    @Published var errorMessage: String = ""
    @Published var showError: Bool = false
    @Published var isLoading: Bool = false
    
    @Published var logStatus: Bool = UserDefaults.standard.bool(forKey: "log_status")
    @Published var userNameStored: String = (UserDefaults.standard.string(forKey: "user_name") ?? "")
    @Published var userUID: String = (UserDefaults.standard.string(forKey: "user_UID") ?? "")
    @Published var userProfileUrl = UserDefaults.standard.url(forKey: "user_profile_url")
    
    func registerUser() {
        isLoading = true
        closeKeyboard()
        Task {
            do {
                try await Auth.auth().createUser(withEmail: email, password: password)
                guard let userUID = Auth.auth().currentUser?.uid else { return }
                guard let imageData = userProfilePicData else { return }
                let storageRef = Storage.storage().reference().child("Profile_Images").child(userUID)
                let _ = try await storageRef.putDataAsync(imageData)
                let downloadURL = try await storageRef.downloadURL()
                
                let user = User(username: username, userBio: userBio, userBioLink: userBioLink, UserUID: userUID, userEmail: email, userProfileURL: downloadURL)
                
                let _ = try Firestore.firestore().collection("users").document(userUID).setData(from: user, completion: { error in
                    if error == nil {
                        print("Saved Succesfully")
                        UserDefaults.standard.set(self.username, forKey: "user_name")
                        UserDefaults.standard.set(userUID, forKey: "user_UID")
                        UserDefaults.standard.set(downloadURL, forKey: "user_profile_url")
                        UserDefaults.standard.set(true,forKey: "log_status")
                        self.isLoading = false
                    }
                })
            } catch {
                await setError(error)
            }
        }
    }
    
    func setError(_ error: Error) async {
        await MainActor.run(body: {
            errorMessage = error.localizedDescription
            showError.toggle()
            isLoading = false
        })
    }
    
    func closeKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

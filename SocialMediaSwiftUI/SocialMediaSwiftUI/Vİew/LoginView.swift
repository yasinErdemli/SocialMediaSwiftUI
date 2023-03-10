//
//  LoginView.swift
//  SocialMediaSwiftUI
//
//  Created by Yasin Erdemli on 10.03.2023.
//

import SwiftUI
import PhotosUI
import Firebase
import FirebaseFirestore
import FirebaseStorage
import FirebaseFirestoreSwift

struct LoginView: View {
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var createAccount: Bool = false
    @State private var showError: Bool = false
    @State private var errorMessage: String = ""
    @State private var isLoading: Bool = false
    @AppStorage("log_status") var logStatus: Bool = false
    @AppStorage("user_profile_url") var userProfileUrl: URL?
    @AppStorage("user_name") var userNameStored: String = ""
    @AppStorage("user_UID") var userUID: String = ""
    var body: some View {
        VStack(spacing: 10) {
            Text("Lets Sign You In")
                .font(.largeTitle)
                .hAlign(.leading)
            
            Text("Welcome Back\nYou Have been missed")
                .font(.title3)
                .hAlign(.leading)
            
            VStack(spacing: 12) {
                TextField("Email", text: $email)
                    .textContentType(.emailAddress)
                    .border(1, .gray.opacity(0.5))
                    .padding(.top,25)
                
                SecureField("Password", text: $password)
                    .textContentType(.password)
                    .border(1, .gray.opacity(0.5))
                    
                Button("Reset Password?", action: resetPassword)
                    .font(.callout)
                    .fontWeight(.medium)
                    .tint(.black)
                    .hAlign(.trailing)
                
                Button {
                    loginUser()
                } label: {
                    Text("Sign In")
                        .foregroundColor(.white)
                        .hAlign(.center)
                        .FillView(.black)
                }
                .padding(.top, 10)
            }
            
            HStack {
                Text("Don't have an account?")
                    .foregroundColor(.gray)
                
                Button("Register now!") {
                    createAccount.toggle()
                }
                .bold()
                .foregroundColor(.black)
            }
            .font(.callout)
            .vAlign(.bottom)
        }
        .vAlign(.top)
        .padding(15)
        .overlay(content: {
            LoadingView(show: $isLoading)
        })
        .fullScreenCover(isPresented: $createAccount) {
            RegisterView()
        }
        .alert(errorMessage, isPresented: $showError, actions: {})
    }
    func loginUser() {
        isLoading = true
        Task {
            do {
                try await Auth.auth().signIn(withEmail: email, password: password)
                try await fetchUser()
            } catch {
                await setError(error)
            }
        }
    }
    
    func fetchUser() async throws {
        guard let userID = Auth.auth().currentUser?.uid else { return }
        let user = try await Firestore.firestore().collection("users").document(userID).getDocument(as: User.self)
        await MainActor.run(body: {
            userUID = userID
            userProfileUrl = user.userProfileURL
            userNameStored = user.username
            logStatus = true
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
}

struct RegisterView: View {
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var username: String = ""
    @State private var userBio: String = ""
    @State private var userBioLink: String = ""
    @State private var userProfilePicData: Data?
    @Environment(\.dismiss) var dismiss
    @State private var showImagePicker: Bool = false
    @State private var photoItem: PhotosPickerItem?
    @State private var errorMessage: String = ""
    @State private var showError: Bool = false
    @State private var isLoading: Bool = false
    
    @AppStorage("log_status") var logStatus: Bool = false
    @AppStorage("user_profile_url") var userProfileUrl: URL?
    @AppStorage("user_name") var userNameStored: String = ""
    @AppStorage("user_UID") var userUID: String = ""
    var body: some View {
        VStack() {
            Text("Let's Register")
                .font(.largeTitle)
                .hAlign(.leading)
            
            Text("Hello new user\nCreate an account")
                .font(.title3)
                .hAlign(.leading)
            
            ViewThatFits {
                HelperView()
                ScrollView(.vertical, showsIndicators: false) {
                    HelperView()
                }
            }
            
            
            HStack {
                Text("Already have an account?")
                    .foregroundColor(.gray)
                
                Button("Let's sign up!") {
                    dismiss()
                }
                .bold()
                .foregroundColor(.black)
            }
            .padding(.top, 25)
            .font(.callout)
        }
        .padding()
        .overlay(content: {
            LoadingView(show: $isLoading)
        })
        .photosPicker(isPresented: $showImagePicker, selection: $photoItem)
        .onChange(of: photoItem) { newValue in
            Task {
                do {
                    guard let imageData = try await newValue?.loadTransferable(type: Data.self) else { return }
                    await MainActor.run(body: {
                        userProfilePicData = imageData
                    })
                } catch {
                    
                }
            }
        }
        .alert(errorMessage, isPresented: $showError, actions: {})
    }
    
    @ViewBuilder
    func HelperView() -> some View {
        VStack(spacing: 12) {
            
            ZStack {
                if let userProfilePicData, let image = UIImage(data: userProfilePicData) {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                } else {
                    Image("NullProfile")
                        .resizable()
                        .scaledToFill()
                }
            }
            .frame(width: 85, height: 85)
            .clipShape(Circle())
            .contentShape(Circle())
            .onTapGesture {
                showImagePicker.toggle()
            }
            .padding(.top, 25)
            
            TextField("Username", text: $username)
                .textContentType(.username)
                .border(1, .gray.opacity(0.5))
                .padding(.top,25)
            
            TextField("Email", text: $email)
                .textContentType(.emailAddress)
                .border(1, .gray.opacity(0.5))

            
            SecureField("Password", text: $password)
                .textContentType(.password)
                .border(1, .gray.opacity(0.5))
            
            TextField("About You", text: $userBio, axis: .vertical)
                .frame(minHeight: 100, alignment: .top)
                .textContentType(.none)
                .border(1, .gray.opacity(0.5))
            
            TextField("Bio Link(optional)", text: $userBioLink)
                .textContentType(.URL)
                .border(1, .gray.opacity(0.5))
            

            Button {
                registerUser()
            } label: {
                Text("Sign up")
                    .foregroundColor(.white)
                    .hAlign(.center)
                    .FillView(.black)
            }
            .padding(.top, 10)
            .disableWithOpacity(username == "" || userBio == "" || email == "" || password == "" || userProfilePicData == nil )
        }
    }
    
    func registerUser() {
        isLoading = true
        Task {
            do {
                try await Auth.auth().createUser(withEmail: email, password: password)
                guard let userUID = Auth.auth().currentUser?.uid else { return }
                guard let imageData = userProfilePicData else { return }
                let storageRef = Storage.storage().reference().child("Profile_Images").child(userUID)
                let _ = try await storageRef.putDataAsync(imageData)
                let downloadURL = try await storageRef.downloadURL()
                
                let user = User(username: username, userBio: userBio, userBioLink: userBioLink, UserUID: userUID, userEmail: email, userProfileURL: downloadURL)
                
                let _ = try Firestore.firestore().collection("Users").document(userUID).setData(from: user, completion: { error in
                    if error == nil {
                        print("Saved Succesfully")
                        userNameStored = username
                        self.userUID = userUID
                        userProfileUrl = downloadURL
                        logStatus = true
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
    
}



struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        RegisterView()
    }
}

extension View {
    func disableWithOpacity(_ condition: Bool) -> some View {
        self
            .disabled(condition)
            .opacity(condition ? 0.6 : 1.0)
    }
    
    func hAlign(_ alignment: Alignment) -> some View {
        self
            .frame(maxWidth: .infinity, alignment: alignment)
    }
    
    func vAlign(_ alignment: Alignment) -> some View {
        self
            .frame(maxHeight: .infinity, alignment: alignment)
    }
    
    func border(_ width: CGFloat, _ color: Color) -> some View {
        self
            .padding(.horizontal, 15)
            .padding(.vertical, 10)
            .background {
                RoundedRectangle(cornerRadius: 5, style: .continuous)
                    .stroke(color, lineWidth: width)
            }
    }
    
    func FillView(_ color: Color) -> some View {
        self
            .padding(.horizontal, 15)
            .padding(.vertical, 10)
            .background {
                RoundedRectangle(cornerRadius: 5, style: .continuous)
                    .fill(color)
            }
    }
}

//
//  RegisterView.swift
//  SocialMediaSwiftUI
//
//  Created by Yasin Erdemli on 14.03.2023.
//

import SwiftUI


struct RegisterView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var viewModel: RegisterViewModel
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
            LoadingView(show: $viewModel.isLoading)
        })
        .photosPicker(isPresented: $viewModel.showImagePicker, selection: $viewModel.photoItem)
        .onChange(of: viewModel.photoItem) { newValue in
            Task {
                do {
                    guard let imageData = try await newValue?.loadTransferable(type: Data.self) else { return }
                    await MainActor.run(body: {
                        viewModel.userProfilePicData = imageData
                    })
                } catch {
                    
                }
            }
        }
        .alert(viewModel.errorMessage, isPresented: $viewModel.showError, actions: {})
    }
    
    @ViewBuilder
    func HelperView() -> some View {
        VStack(spacing: 12) {
            
            ZStack {
                if let userProfilePicData = viewModel.userProfilePicData, let image = UIImage(data: userProfilePicData) {
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
                viewModel.showImagePicker.toggle()
            }
            .padding(.top, 25)
            
            TextField("Username", text: $viewModel.username)
                .textContentType(.username)
                .border(1, .gray.opacity(0.5))
                .padding(.top,25)
            
            TextField("Email", text: $viewModel.email)
                .textContentType(.emailAddress)
                .border(1, .gray.opacity(0.5))

            
            SecureField("Password", text: $viewModel.password)
                .textContentType(.password)
                .border(1, .gray.opacity(0.5))
            
            TextField("About You", text: $viewModel.userBio, axis: .vertical)
                .frame(minHeight: 100, alignment: .top)
                .textContentType(.none)
                .border(1, .gray.opacity(0.5))
            
            TextField("Bio Link(optional)", text: $viewModel.userBioLink)
                .textContentType(.URL)
                .border(1, .gray.opacity(0.5))
            

            Button {
                viewModel.registerUser()
            } label: {
                Text("Sign up")
                    .foregroundColor(.white)
                    .hAlign(.center)
                    .FillView(.black)
            }
            .padding(.top, 10)
            .disableWithOpacity(viewModel.username == "" || viewModel.userBio == "" || viewModel.email == "" || viewModel.password == "" || viewModel.userProfilePicData == nil )
        }
    }
}

struct RegisterView_Previews: PreviewProvider {
    static var previews: some View {
        RegisterView(viewModel: RegisterViewModel())
    }
}

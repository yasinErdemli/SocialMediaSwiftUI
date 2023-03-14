//
//  ContentView.swift
//  SocialMediaSwiftUI
//
//  Created by Yasin Erdemli on 10.03.2023.
//

import SwiftUI

struct ContentView: View {
    @StateObject var viewModel = LoginViewModel()
    @StateObject var registerViewModel = RegisterViewModel()
    var body: some View {
        if viewModel.logStatus || registerViewModel.logStatus {
            Text("Main View")
        } else {
            LoginView(viewModel: viewModel, registerViewModel: registerViewModel)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

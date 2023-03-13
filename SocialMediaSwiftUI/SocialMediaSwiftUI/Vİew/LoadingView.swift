//
//  LoadingView.swift
//  SocialMediaSwiftUI
//
//  Created by Yasin Erdemli on 12.03.2023.
//

import SwiftUI

struct LoadingView: View {
    @Binding var show: Bool
    var body: some View {
        ZStack{
            Group{
                if show{
                    Rectangle()
                        .fill(.black.opacity(0.25))
                        .ignoresSafeArea()
                    ProgressView()
                        .padding (15)
                        .background(.white,in: RoundedRectangle(cornerRadius: 10, style: .continuous))
                        .animation(.easeInOut(duration: 0.25), value: show)
                }
            }
        }
    }
}

                            
struct LoadingView_Previews: PreviewProvider {
    static var previews: some View {
        LoadingView(show: .constant(true))
    }
}

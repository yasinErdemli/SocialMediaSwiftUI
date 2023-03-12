//
//  User.swift
//  SocialMediaSwiftUI
//
//  Created by Yasin Erdemli on 12.03.2023.
//

import Foundation
import FirebaseFirestoreSwift


struct User: Identifiable, Codable {
    @DocumentID var id: String?
    var username: String
    var userBio: String
    var userBioLink: String
    var UserUID: String
    var userEmail: String
    var userProfileURL: URL
    
    enum CodingKeys: CodingKey {
        case id
        case username
        case userBio
        case userBioLink
        case UserUID
        case userEmail
        case userProfileURL
    }
}

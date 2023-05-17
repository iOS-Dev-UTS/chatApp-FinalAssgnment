//
//  DatabaseManager.swift
//  ChatApp
//
//  Created by 安達さくら on 2023/05/15.
//


// Public DB APIs

import Foundation
import FirebaseDatabase

final class DatabaseManager {
    static let shared = DatabaseManager()
    
    private let database = Database.database().reference()
    
}

// MARK: - Account Management
extension DatabaseManager {
    ///
    public func isUserExists(with email: String, completion: @escaping((Bool) -> Void)){ // Use completion as it's an asyncronous function
        
        // Convert to the safe email
        var validEmail = email.replacingOccurrences(of: ".", with: "-")
        validEmail = validEmail.replacingOccurrences(of: "@", with: "-")
        database.child(validEmail).observeSingleEvent(of: .value, with: {snapshot in
            guard snapshot.value as? String != nil else {
                // doesn't exist
                completion(false)
                return
            }
            // exists
            // doesn't come here even though it's already exists!!!
            print("should be here")
            completion(true)
        })
         
    }
    
    /// Inserts new user to the database
    public func insertUser(with user: ChatAppUser){
        database.child(user.validEmail).setValue([
            "first_name": user.firstName,
            "last_name": user.lastName
        ])
    }
}


struct ChatAppUser {
    let firstName: String
    let lastName: String
    let emailAddress: String
    // let profilePicUrl: String
    
    // Insert safe email to insert
    var validEmail: String {
        var validEmail = emailAddress.replacingOccurrences(of: ".", with: "-")
        validEmail = validEmail.replacingOccurrences(of: "@", with: "-")
        return validEmail
    }
}

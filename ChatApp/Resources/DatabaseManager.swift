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
        
        self.database.child("users").observeSingleEvent(of: .value, with: { snapshot in
            if var usersCollection = snapshot.value as? [[String: String]] {
                //add to user dict
                let newElement = [
                    ["name": user.firstName + " " + user.lastName,
                     "email": user.validEmail]
                ]
                usersCollection.append(contentsOf: newElement)
                self.database.child("users").setValue(usersCollection)
            } else {
                //create dict
                let newCollection: [[String: String]] = [
                    ["name": user.firstName + " " + user.lastName,
                     "email": user.validEmail]
                ]
                self.database.child("users").setValue(newCollection)
            }
        })
    }
    
    public func getAllUsers(completion: @escaping (Result<[[String: String]], Error>) -> Void) {
        database.child("users").observeSingleEvent(of: .value, with: {snapshot in
            guard let value = snapshot.value as? [[String: String]] else {
                return
            }
            completion(.success(value))
        })
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

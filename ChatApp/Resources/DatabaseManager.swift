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
    
    
    static func validEmail(emailAddress: String) -> String {
        var validEmail = emailAddress.replacingOccurrences(of: ".", with: "-")
        validEmail = validEmail.replacingOccurrences(of: "@", with: "-")
        return validEmail
    }
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
    public func insertUser(with user: ChatAppUser, completion: @escaping (Bool) -> Void){
        database.child(user.validEmail).setValue([
            "first_name": user.firstName,
            "last_name": user.lastName
        ], withCompletionBlock: {error, _ in
            guard error == nil else {
                print("Failed to write to Firebase")
                completion(false)
                return
            }
            completion(true)
        })
        
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
    
    public enum DatabaseError: Error {
            case failedToFetch

            public var localizedDescription: String {
                switch self {
                case .failedToFetch:
                    return "This means blah failed"
                }
            }
        }
}

extension DatabaseManager {
    
    /// Create a new conversation with a searched user
    public func createNewConversation(with otherUserEmail: String, name: String, firstMessage: Message, completion: @escaping (Bool) -> Void) {
        guard let currentEmail = UserDefaults.standard.value(forKey: "email") as? String else {
            return
        }
        let validEmail = DatabaseManager.validEmail(emailAddress: currentEmail)
        
        let ref = database.child("\(validEmail)")
        ref.observeSingleEvent(of: .value, with: { snapshot in
            guard var userNode = snapshot.value as? [String: Any] else {
                completion(false)
                print("user not found")
                return
            }
            let messageDate = firstMessage.sentDate
            let dateString = ChatViewController.dateFormatter.string(from: messageDate)
            
            var message = ""
            
            switch firstMessage.kind {
            case .text(let messageText):
                message = messageText
            case .attributedText(_):
                break
            case .photo(_):
                break
            case .video(_):
                break
            case .location(_):
                break
            case .emoji(_):
                break
            case .audio(_):
                break
            case .contact(_):
                break
            case .linkPreview(_):
                break
            case .custom(_):
                break
            }
                
            let conversationId = "conversation_\(firstMessage.messageId)"
            
            let newConversationData: [String: Any] = [
                "id": conversationId,
                "other_user_email": otherUserEmail,
                "name": name,
                "latest_message": [
                    "date": dateString,
                    "message": message,
                    "is_read": false
                ]
            ]
            
            if var conversations = userNode["conversations"] as? [[String: Any]] {
                conversations.append(newConversationData)
                userNode["conversations"] = conversations
                ref.setValue(userNode, withCompletionBlock: { [weak self] error, _ in
                    guard error == nil else {
                        completion(false)
                        return
                    }
                    self?.finishCreatingConversation(name: name, conversationId: conversationId, firstMessage: firstMessage, completion: completion)
                })
            } else {
                userNode["conversations"] = [
                    newConversationData
                ]
                
                ref.setValue(userNode, withCompletionBlock: { [weak self] error, _ in
                    guard error == nil else {
                        completion(false)
                        return
                    }
                    self?.finishCreatingConversation(name: name, conversationId: conversationId, firstMessage: firstMessage, completion: completion)
                
                })
            }
        })
    }
    
    private func finishCreatingConversation(name: String, conversationId: String, firstMessage: Message, completion: @escaping (Bool) -> Void) {
        
        let messageDate = firstMessage.sentDate
        let dateString = ChatViewController.dateFormatter.string(from: messageDate)
        
        
        var message = ""
        switch firstMessage.kind {
        case .text(let messageText):
            message = messageText
        case .attributedText(_):
            break
        case .photo(_):
            break
        case .video(_):
            break
        case .location(_):
            break
        case .emoji(_):
            break
        case .audio(_):
            break
        case .contact(_):
            break
        case .linkPreview(_):
            break
        case .custom(_):
            break
        }
            
        guard let myEmail = UserDefaults.standard.value(forKey: "email") as? String else {
            completion(false)
            return
        }
        let currentUserEmail = DatabaseManager.validEmail(emailAddress: myEmail)
        
        let collectionMessage: [String: Any] = [
            "id": firstMessage.messageId,
            "type": firstMessage.kind.messageKindString,
            "content": message,
            "date": dateString,
            "sender_email": currentUserEmail,
            "is_read": false,
            "name": name
        ]
        
        let value: [String: Any] = [
            "messages": [
                collectionMessage
            ]
        ]
        
        database.child("\(conversationId)").setValue(value, withCompletionBlock: { error, _ in
            guard error == nil else {
                completion(false)
                return
            }
            completion(true)
        })
    }
    
    public func getAllConversations(for email: String, completion: @escaping (Result<[Conversation], Error>) -> Void) {
        database.child("\(email)/conversations").observe(.value, with: { snapshot in
            guard let value = snapshot.value as? [[String:Any]] else {
                completion(.failure(DatabaseError.failedToFetch))
                return
            }
            
            print("test")
            
            let conversations: [Conversation] = value.compactMap({ dictionary in
                            guard let conversationId = dictionary["id"] as? String,
                                let name = dictionary["name"] as? String,
                                let otherUserEmail = dictionary["other_user_email"] as? String,
                                let latestMessage = dictionary["latest_message"] as? [String: Any],
                                let date = latestMessage["date"] as? String,
                                let message = latestMessage["message"] as? String,
                                let isRead = latestMessage["is_read"] as? Bool else {
                                    return nil
                            }
                
                let latestMessageObject = LatestMessage(date: date, text: message, isRead: isRead)
                
                return Conversation(id: conversationId, name: name, otherUserEmail: otherUserEmail, latestMessage: latestMessageObject)
            })
            print("test 2")
            completion(.success(conversations))
        })
    }
    
    public func getAllMessagesForConversation(with id: String, completion: @escaping (Result<String, Error>) -> Void) {
        
    }
    
    public func sendMessage(to conversation: String, message: Message, completion: @escaping (Bool) -> Void) {
        
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
    
    var profilePictureFileName: String {
        return "\(validEmail)_profile_picture.png"
    }
}



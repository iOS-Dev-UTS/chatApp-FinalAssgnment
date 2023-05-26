//
//  ChatViewController.swift
//  ChatApp
//
//  Created by Vuong Do Tuan Thanh on 24/05/2023.
//

import UIKit
import MessageKit
import InputBarAccessoryView

struct Message: MessageType {
    var sender: MessageKit.SenderType
    
    var messageId: String
    
    var sentDate: Date
    
    var kind: MessageKit.MessageKind
    
    
}

struct Sender: SenderType {
    var photoURL: String
    
    var senderId: String
    
    var displayName: String
    
    
}

class ChatViewController: MessagesViewController {
    
    public static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .long
        formatter.locale = .current
        return formatter
    }()
    
    public var isNewConversation = false
    public let otherUserEmail: String
    
    private var messages = [Message]()
    
    private var selfSender: Sender? {
        guard let email = UserDefaults.standard.value(forKey: "email") as? String else {
            print("sender error")
            return nil
        }
        return Sender(photoURL: "", senderId: email, displayName: "John Smith")
    }
    
    init(with email: String) {
        self.otherUserEmail = email
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
//        messages.append(Message(sender: selfSender, messageId: "1", sentDate: Date(), kind: .text("Hello World")))
//        
//        messages.append(Message(sender: selfSender, messageId: "2", sentDate: Date(), kind: .text("Hello World Hello World Hello World Hello World")))
//
        view.backgroundColor = .red
        
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
        messageInputBar.delegate = self
        
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        messageInputBar.inputTextView.becomeFirstResponder()
    }
    
}
extension ChatViewController: InputBarAccessoryViewDelegate {
    
    func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String) {
        guard !text.replacingOccurrences(of: " ", with: "").isEmpty,
              let selfSender = self.selfSender,
              let messageId = createMessageId()
        else {
            print("send error")
            return
        }
        
        print("Sending: \(text)")
        
        if isNewConversation {
            let message = Message(sender: selfSender,
                                  messageId: messageId,
                                  sentDate: Date(),
                                  kind: .text(text))
            
            DatabaseManager.shared.createNewConversation(with: otherUserEmail, firstMesage: message, completion: { success in
                if success {
                    print("message sent")
                } else {
                    print("failed to send")
                }
            })
        } else {
            
        }
        
    }
    
    private func createMessageId() -> String? {
        guard let currentUserEmail = UserDefaults.standard.value(forKey: "email") else {
            print("id error")
            return nil
        }
        let dateString = Self.dateFormatter.string(from: Date())
        let newId = "\(otherUserEmail)_\(currentUserEmail)_\(dateString)"
        print("created message id: \(newId)")
        return newId
    }
    
}

extension ChatViewController: MessagesDataSource, MessagesLayoutDelegate, MessagesDisplayDelegate {
    func currentSender() -> MessageKit.SenderType {
        if let sender = selfSender {
            return sender
        }
        fatalError("Self sender is nil")
        return Sender(photoURL: "", senderId: "0", displayName: "")
    }
    
    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessageKit.MessagesCollectionView) -> MessageKit.MessageType {
        return messages[indexPath.section]
    }
    
    func numberOfSections(in messagesCollectionView: MessageKit.MessagesCollectionView) -> Int {
        return messages.count
    }
    
    
}

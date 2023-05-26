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
    
    public var isNewConversation = false
    public let otherUserEmail: String
    
    private var messages = [Message]()
    
    private let selfSender = Sender(photoURL: "", senderId: "1", displayName: "John Smith")
    
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
        guard !text.replacingOccurrences(of: " ", with: "").isEmpty else {
            return
        }
        print("Sending: \(text)")
        
        if isNewConversation {
            
        } else {
            
        }
        
    }
    
}

extension ChatViewController: MessagesDataSource, MessagesLayoutDelegate, MessagesDisplayDelegate {
    func currentSender() -> MessageKit.SenderType {
        return selfSender
    }
    
    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessageKit.MessagesCollectionView) -> MessageKit.MessageType {
        return messages[indexPath.section]
    }
    
    func numberOfSections(in messagesCollectionView: MessageKit.MessagesCollectionView) -> Int {
        return messages.count
    }
    
    
}

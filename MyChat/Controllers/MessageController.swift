//
//  MessageController.swift
//  MyChat
//
//  Created by Marc Lee on 10/8/19.
//  Copyright © 2019 Marc Lee. All rights reserved.
//

import UIKit
import Firebase

// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
    switch (lhs, rhs) {
    case let (l?, r?):
        return l < r
    case (nil, _?):
        return true
    default:
        return false
    }
}

// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func > <T: Comparable>(lhs: T?, rhs: T?) -> Bool {
    switch (lhs, rhs) {
    case let (l?, r?):
        return l > r
    default:
        return rhs < lhs
    }
}

class MessageController: UITableViewController {

    let cellId = "cellId"
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Logout", style: .plain, target: self, action: #selector(handleLogout))
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "New", style: .plain, target: self, action: #selector(handleNewMessage))
        
        checkIfUserIsLoggedIn()
        
        tableView.register(UserCell.self, forCellReuseIdentifier: cellId)
        
//        observeMessages()
        
//        observeUserMessages()
    }
    var messages = [Message]()
    var messagesDictionary = [String: Message]()
    func observeUserMessages() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let ref = Database.database().reference().child("user-messages").child(uid)
        ref.observe(.childAdded, with: { (snapshot) in
            
            let messageId = snapshot.key
            let messagesReference = Database.database().reference().child("messages").child(messageId)
            
            messagesReference.observeSingleEvent(of: .value, with: {(snapshot) in
                if let dictionary = snapshot.value as? [String: AnyObject] {
                    let message = Message(dictionary: dictionary)
                    
                    if let toId = message.toId {
                        self.messagesDictionary[toId] = message
                        self.messages = Array(self.messagesDictionary.values)
                        self.messages.sort(by: {(message1, message2) -> Bool in
                            if let timestamp1 = message1.timestamp, let timestamp2 = message2.timestamp {
                                return timestamp1.intValue > timestamp2.intValue
                            }
                            return false
                        })
                    }
                    
                    DispatchQueue.main.async(execute: {
                        self.tableView.reloadData()
                    })
                }
            }, withCancel: nil)
        }, withCancel: nil)
    }
//    func observeMessages() {
//        let ref = Database.database().reference().child("messages")
//        ref.observe(.childAdded, with: { (snapshot) in
//            
//            if let dictionary = snapshot.value as? [String: AnyObject] {
//                let message = Message(dictionary: dictionary)
////                self.messages.append(message)
//                
//                if let toId = message.toId {
//                    self.messagesDictionary[toId] = message
//                    self.messages = Array(self.messagesDictionary.values)
//                    self.messages.sort(by: {(message1, message2) -> Bool in
//                        return message1.timestamp?.int32Value > message2.timestamp?.int32Value
//                    })
//                }
//                
//                DispatchQueue.main.async {
//                    self.tableView.reloadData()
//                }
//            }
//        }, withCancel: nil)
//    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "cellId")
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId , for: indexPath) as! UserCell
        let message = messages[indexPath.row]
        cell.message = message
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 72
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let message = messages[indexPath.row]
        
        guard let chatPartnerId = message.chatPartnerId() else {
            return
        }
        
        let ref = Database.database().reference().child("users").child(chatPartnerId)
        ref.observeSingleEvent(of: .value, with: { (snapshot) in
            guard let dictionary = snapshot.value as? [String: AnyObject] else {
                return
            }
            
            let user = User(dictionary: dictionary)
            user.id = chatPartnerId
            self.showChatController(user: user)
        }, withCancel: nil)
    }
    
    @objc func handleNewMessage() {
        let newMessageController = NewMessageController()
        newMessageController.messageController = self
        let navController = UINavigationController(rootViewController: newMessageController)
        present(navController, animated: true, completion: nil)
    }
    
    func checkIfUserIsLoggedIn() {
        if Auth.auth().currentUser?.uid == nil {
            perform(#selector(handleLogout), with: nil, afterDelay: 0)
        } else {
            fetchUserAndSetupNavBarTitle()
        }
    }
    
    func fetchUserAndSetupNavBarTitle() {
        guard let uid = Auth.auth().currentUser?.uid else {
            // for some reason uid = nil
            return
        }
        Database.database().reference().child("users").child(uid).observe(.value, with: { (snapshot) in
            
            if let dictionary = snapshot.value as? [String: AnyObject] {
                
                let user = User(dictionary: dictionary)
//                user.setValues(dict: dictionary)
                self.setupNavbarWithUser(user: user)
            }
        }, withCancel: nil)
    }
    
    func setupNavbarWithUser(user: User) {
        messages.removeAll()
        messagesDictionary.removeAll()
        tableView.reloadData()
        
        observeUserMessages()
        
        let titleView = CustomTitleView()

        let containerView = UIView()
        containerView.translatesAutoresizingMaskIntoConstraints = false


        titleView.addSubview(containerView)

        let profileImageView = UIImageView()
        profileImageView.translatesAutoresizingMaskIntoConstraints = false
        profileImageView.contentMode = .scaleAspectFill
        profileImageView.layer.cornerRadius = 20
        profileImageView.clipsToBounds = true
        if let profileImageUrl = user.imageURL {
            profileImageView.loadImageUsingCacheWithUrlString(urlString: profileImageUrl)
        }

        titleView.addSubview(profileImageView)

        // need x, y, width, height anchors
        profileImageView.leftAnchor.constraint(equalTo: titleView.leftAnchor).isActive = true
        profileImageView.centerYAnchor.constraint(equalTo: titleView.centerYAnchor).isActive = true
        profileImageView.widthAnchor.constraint(equalToConstant: 40).isActive = true
        profileImageView.heightAnchor.constraint(equalToConstant: 40).isActive = true

        let nameLabel = UILabel()
        nameLabel.text = user.name
        nameLabel.translatesAutoresizingMaskIntoConstraints = false

        titleView.addSubview(nameLabel)

        //need x, y, width, height constraints
        nameLabel.leftAnchor.constraint(equalTo: profileImageView.rightAnchor, constant: 8).isActive = true
        nameLabel.centerYAnchor.constraint(equalTo: profileImageView.centerYAnchor).isActive = true
        nameLabel.rightAnchor.constraint(equalTo: titleView.rightAnchor).isActive = true
        nameLabel.heightAnchor.constraint(equalTo: profileImageView.heightAnchor).isActive = true

        //Center the containerView
        containerView.centerXAnchor.constraint(equalTo: titleView.centerXAnchor).isActive = true
        containerView.centerYAnchor.constraint(equalTo: titleView.centerYAnchor).isActive = true

        self.navigationItem.titleView = titleView
//        titleView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(showChatController)))

}
    
    @objc func showChatController(user: User) {
        let chatLogController = ChatLogController(collectionViewLayout: UICollectionViewFlowLayout())
        chatLogController.user = user
        navigationController?.pushViewController(chatLogController, animated: true)
    }
    
    @objc func handleLogout() {
        do {
            try Auth.auth().signOut()
        } catch let logoutError {
            print(logoutError)
        }
        let loginController = LoginController()
        loginController.messageController = self
        present(loginController, animated: true, completion: nil)
    }
}

class CustomTitleView: UIView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.frame = CGRect(x: 0, y: 0, width: 100.0, height: 40.0)
        self.isUserInteractionEnabled = true
    }
    
    override var intrinsicContentSize: CGSize {
        return CGSize(width: 100.0, height: 40.0)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


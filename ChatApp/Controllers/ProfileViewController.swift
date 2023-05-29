//
//  ProfileViewController.swift
//  ChatApp
//
//  Created by 安達さくら on 2023/05/06.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseStorage
import GoogleSignIn
import SDWebImage


enum ProfileModelType {
    case info
}

struct ProfileModel {
    let modelType: ProfileModelType
    let title: String
    let handler: (() ->Void)?
}

class ProfileViewController: UIViewController {
    
    @IBOutlet var tableview: UITableView!
    
    var data = [ProfileModel]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableview.register(ProfileTableViewCell.self, forCellReuseIdentifier: ProfileTableViewCell.identifier)
        
        
        data.append(ProfileModel(modelType: .info, title: "Name: \(UserDefaults.standard.value(forKey: "name") as? String ?? "No Name")", handler: nil))
        data.append(ProfileModel(modelType: .info, title: "Email: \(UserDefaults.standard.value(forKey: "email") as? String ?? "No Email")", handler: nil))
        
        tableview.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableview.delegate = self
        tableview.dataSource = self
        tableview.tableHeaderView = createTableHeader()

    }
    
    func createTableHeader() -> UIView? {
        guard let email = UserDefaults.standard.value(forKey: "email") as? String else {
            return nil
        }
        
        let validEmail = DatabaseManager.validEmail(emailAddress: email)
        let filename = validEmail + "_profile_picture.png"
        
        let path = "images/" + filename
        
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: self.view.width, height: 300))
        headerView.backgroundColor = .link
        
        let imageView = UIImageView(frame: CGRect(x: (headerView.width-150)/2, y: 75, width: 150, height: 150))
        
        imageView.contentMode = .scaleAspectFill
        imageView.backgroundColor = .white
        imageView.layer.borderColor = UIColor.white.cgColor
        imageView.layer.borderWidth = 3
        imageView.layer.masksToBounds = true
        imageView.layer.cornerRadius = imageView.width/2

        headerView.addSubview(imageView)

        StorageManager.shared.downloadURL(for: path, completion: { [weak self] result in
            switch result {
            case .success(let url):
                self?.downloadImage(imageView: imageView, url: url)
            case .failure(let error):
                print("Failed to get download url: \(error)")
            }
        })
        
        return headerView
    }
    
    func downloadImage(imageView: UIImageView, url: URL) {
        URLSession.shared.dataTask(with: url, completionHandler: {data, _, error in
            guard let data = data, error == nil else {
                return
            }
            DispatchQueue.main.async {
                let image = UIImage(data: data)
                imageView.image = image
            }
        }).resume()
    }

}

extension ProfileViewController: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let viewModel = data[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: ProfileTableViewCell.identifier, for: indexPath) as! ProfileTableViewCell
        
        cell.setUp(with: viewModel)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        data[indexPath.row].handler?()
    
    }
}

class ProfileTableViewCell: UITableViewCell {
    
    static let identifier = "ProfileTableViewCell"
    
    private var viewModel: ProfileModel?
    
    public func setUp(with viewModel: ProfileModel) {
        self.viewModel = viewModel
        self.textLabel?.textAlignment = .left
        selectionStyle = .none

        self.textLabel?.text = viewModel.title
        
        if viewModel.modelType == .info{
            
        }
    }
  
    }



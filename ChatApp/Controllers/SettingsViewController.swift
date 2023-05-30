//
//  SettingsViewController.swift
//  ChatApp
//
//  Created by Eduardo  Moraza on 25/5/2023.
//

import UIKit
import FirebaseAuth
import GoogleSignIn

class SettingsViewController: UIViewController {
    
    @IBOutlet var tableview: UITableView!
    
    let data = ["Dark Mode", "Log Out"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //Register the cell
        tableview.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        
        //Set the delegate and data source
        tableview.delegate = self
        tableview.dataSource = self
        
        // Set the initial appearance
        DarkModeManager.shared.updateAppearance()
          }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Save the Dark Mode setting when the view disappears
        DarkModeManager.shared.saveSettings()
    }
}


extension SettingsViewController: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = data[indexPath.row]
        cell.textLabel?.textAlignment = .center
        switch indexPath.row {
            case 0:
                cell.accessoryType = DarkModeManager.shared.isDarkModeEnabled ? .checkmark : .none
                cell.detailTextLabel?.text = nil
            case 1:
                cell.accessoryType = .none
                cell.detailTextLabel?.text = nil
            default:
                cell.accessoryType = .none
                cell.detailTextLabel?.text = nil
            }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        
        if indexPath.row == 0 {
            DarkModeManager.shared.toggleDarkMode()
            tableView.reloadData()
        } else {
            let actionSheet = UIAlertController(title: "", message: "", preferredStyle: .actionSheet)
            actionSheet.addAction(UIAlertAction(title: "Log Out", style: .destructive, handler: { [weak self] _ in
                guard let strongSelf = self else {
                    return
                }
                
                // Log Out Google
                GIDSignIn.sharedInstance.signOut()
                
                do {
                    try FirebaseAuth.Auth.auth().signOut()
                    let vc = LoginViewController()
                    let nav = UINavigationController(rootViewController: vc)
                    nav.modalPresentationStyle = .fullScreen
                    strongSelf.present(nav, animated: true)
                } catch {
                    print("Failed to Log Out")
                }
            }))
            
            actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            present(actionSheet, animated: true)
            
        }
    }
}

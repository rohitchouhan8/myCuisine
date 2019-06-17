//
//  SettingsTableViewController.swift
//  myCuisine
//
//  Created by Rohit Chouhan on 5/30/19.
//  Copyright © 2019 Rohit Chouhan. All rights reserved.
//

import UIKit
import Firebase
import FBSDKLoginKit

class SettingsViewController: UIViewController {
    let settings = ["Food Preferences", "Cusines/Diet"]
    @IBOutlet weak var cuisinesButton: UIButton!
    @IBOutlet weak var foodPreferencesButton: UIButton!
    @IBOutlet weak var logoutButton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        foodPreferencesButton.layer.cornerRadius = 8
        cuisinesButton.layer.cornerRadius = 8
        logoutButton.layer.cornerRadius = 8
        updateNavBar()
        updateTabBar()
    }
    func updateNavBar() {
        guard let navBar = navigationController?.navigationBar else {fatalError()}
        navBar.tintColor = UIColor(named: "Dark Gray") ?? .black
        navBar.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor : navBar.tintColor!]
        
    }
    func updateTabBar() {
        guard let tabBar = tabBarController?.tabBar else {fatalError()}
        tabBar.unselectedItemTintColor = UIColor(named: "Main Green") ?? .green
    }
//
    @IBAction func cuisinesButtonPressed(_ sender: UIButton) {
        performSegue(withIdentifier: "goToCuisine", sender: self)
        
    }

    @IBAction func foodPreferencesButtonPressed(_ sender: UIButton) {
        performSegue(withIdentifier: "goToFood", sender: self)
    }
    @IBAction func logoutPressed(_ sender: UIButton) {
        //TODO: Log out the user and send them back to WelcomeViewController
        LoginManager().logOut()
        do {
            try Auth.auth().signOut()
            performSegue(withIdentifier: "unwindToMain", sender: self)
            
        } catch {
            print("Error signing out")
        }
    }

    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        switch segue.identifier {
        case "goToFood":
            let destination = segue.destination as! FoodSelectorViewController
            destination.isFromSetting = true
        case "goToCuisine":
            let destination = segue.destination as! SetupViewController
            destination.isFromSetting = true
        default:
            break
        }
    }
    

    

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

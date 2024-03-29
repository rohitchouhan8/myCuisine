//
//  SignUpViewController.swift
//  myCuisine
//
//  Created by Rohit Chouhan on 5/15/19.
//  Copyright © 2019 Rohit Chouhan. All rights reserved.
//

import UIKit
import Firebase
import SVProgressHUD

class SignUpViewController: UIViewController {

    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var registerButton: UIButton!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    @IBOutlet weak var reenterTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        backButton.layer.cornerRadius = 16
        registerButton.layer.cornerRadius = 16
        // Do any additional setup after loading the view.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

    
    @IBAction func backButtonPressed(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func registerButtonPressed(_ sender: UIButton) {
        
        
        //TODO: Set up a new user on our Firbase database
        if let email = emailTextField.text,
            let rePassword = reenterTextField.text,
            let password = passwordTextField.text {
            print(email)
            if (rePassword == password) {
                Auth.auth().createUser(withEmail: email, password: password) { (user, error) in
                    SVProgressHUD.show()
                    if error != nil {
                        print(String(error!.localizedDescription))
                    } else {
                        //success
                        print("registration successful")
                        self.performSegue(withIdentifier: "goToSetup", sender: self)
                    }
                    SVProgressHUD.dismiss()
                }
            } else {
                SwiftEntryMessages.displayUnsuccessfulLogin(errorMessage: "Passwords do not match.")
            }
        }
        
    }
}

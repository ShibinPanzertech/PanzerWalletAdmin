//
//  ResetPasswordViewController.swift
//  AdminPanzer
//
//  Created by Panzer Tech Pte Ltd on 23/12/19.
//  Copyright © 2019 test.com. All rights reserved.
//

import UIKit
import Firebase

class ResetPasswordViewController: UIViewController {
 
    @IBOutlet weak var txtEmail: UITextField!
    @IBOutlet weak var btnSubmit: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
         self.setUpUI()
    }
    //MARK: setUpUI
    func setUpUI(){
        self.addTapGesture()
        btnSubmit.layer.cornerRadius = 25.0
        btnSubmit.layer.masksToBounds = true
    }
    //MARK: UIButton Action
    @IBAction func actionBack(_ sender: UIButton)
    {
        self.navigationController?.popViewController(animated: true)
    }
    @IBAction func actionSubmit(_ sender: UIButton)
    {
        if self.txtEmail.text == "" {
            let alertController = UIAlertController(title: "Please enter an email", message: "", preferredStyle: .alert)
            
            let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            alertController.addAction(defaultAction)
            
            present(alertController, animated: true, completion: nil)
            
        }
        else if !isValidEmail(emailStr: txtEmail.text!){
            self.showAlert(message: "Please enter a valid email id")
        }
        else {
            Auth.auth().sendPasswordReset(withEmail: self.txtEmail.text!) { (error) in
             
                var title = ""
                var message = ""
                
                if error != nil {
                    title = "Error!"
                    message = (error?.localizedDescription)!
                } else {
                    title = "Success!"
                    message = "Password reset email sent."
                    self.txtEmail.text = ""
                }
                message = message.hasPrefix("There is no user") ? "The user does not exists" : message
                let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
                
                let defaultAction = UIAlertAction(title: "Ok", style: .default, handler: { (action) in
                 //   self.navigationController?.popViewController(animated: true)
                })
                alertController.addAction(defaultAction)
                
                self.present(alertController, animated: true, completion: nil)
            }
        }
    }
    
}
extension ResetPasswordViewController: UITextFieldDelegate{
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

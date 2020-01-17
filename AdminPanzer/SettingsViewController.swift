//
//  SettingsViewController.swift
//  AdminPanzer
//
//  Created by Panzer Tech Pte Ltd on 31/12/19.
//  Copyright © 2019 test.com. All rights reserved.
//

import UIKit
import Firebase

class SettingsViewController: UIViewController {
    @IBOutlet  var outerViews: [UIView]!
    @IBOutlet weak var btnChangePhoneNumber: UIButton!
    @IBOutlet weak var resetPswTopSpace: NSLayoutConstraint!
    override func viewDidLoad() {
        super.viewDidLoad()

        let user = Auth.auth().currentUser
        if user!.email == "apple@panzertech.com"{
            outerViews[0].isHidden = true
            btnChangePhoneNumber.isHidden = true
            resetPswTopSpace.constant = 65.0
        }
        // Do any additional setup after loading the view.
        for outerView in outerViews{
            outerView.dropShadow()
        }
    }
    //MARK: UIButton Action
     @IBAction func actionBack(sender: UIButton){
        _ = self.navigationController?.popViewController(animated: true)
    }
    @IBAction func actionUpdatePassword(sender: UIButton){
        let alertVC = storyboard?.instantiateViewController(withIdentifier: "UpdateDetailsViewController") as! UpdateDetailsViewController
        alertVC.updateType = .updatePassword
        alertVC.alertDelegate = self
        alertVC.modalPresentationStyle = .overFullScreen
        alertVC.view.backgroundColor = UIColor.clear
        self.present(alertVC, animated: false, completion: nil)
    }
    @IBAction func actionUpdatePhone(sender: UIButton){
        let alertVC = storyboard?.instantiateViewController(withIdentifier: "UpdateDetailsViewController") as! UpdateDetailsViewController
        alertVC.updateType = .updatePhoneNumber
        alertVC.alertDelegate = self
        alertVC.modalPresentationStyle = .overFullScreen
        alertVC.view.backgroundColor = UIColor.clear
        self.present(alertVC, animated: false, completion: nil)
    }
    @IBAction func actionLogout(sender: UIButton){
        let alert = UIAlertController(title: "Do you want to logout?", message: "", preferredStyle: .alert)
        
        let okAction = UIAlertAction(title: "Logout", style: .default, handler: { (action) in
            
            do {
                isSignedIn = false
                try Auth.auth().signOut()
                self.navigationController?.popToRootViewController(animated: false)
                
            } catch let error as NSError {
                print(error.localizedDescription)
                   isSignedIn = false
                 self.navigationController?.popToRootViewController(animated: false)
            }
            
        })
        let cancelAction = UIAlertAction(title: "Cancel", style: .default, handler: { (action) in
            
        })
        alert.addAction(okAction)
        alert.addAction(cancelAction)
        
        self.present(alert, animated: true, completion: nil)
    }
            

   

}
extension SettingsViewController: AlertDelegate{
    
}

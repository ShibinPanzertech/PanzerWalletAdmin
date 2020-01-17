//
//  UpdateDetailsViewController.swift
//  AdminPanzer
//
//  Created by Panzer Tech Pte Ltd on 31/12/19.
//  Copyright © 2019 test.com. All rights reserved.
//

import UIKit
import Firebase
enum UpdateType {
    case updatePassword
    case updatePhoneNumber
}
@objc protocol AlertDelegate {
    @objc optional func navigateToHome()
    @objc optional func navigateBack()
}
class UpdateDetailsViewController: UIViewController {
     @IBOutlet weak var txtCurrentCode: UITextField!
     @IBOutlet weak var txtNewCode: UITextField!
    @IBOutlet weak var txtCurrentPassword: UITextField!
    @IBOutlet weak var txtNewPassword: UITextField!
    @IBOutlet weak var txtConfirmPassword: UITextField!
    @IBOutlet weak var txtCurrentPhone: UITextField!
    @IBOutlet weak var txtNewPhone: UITextField!
    @IBOutlet var arrUpdateViews: [UIView]!
    @IBOutlet weak var updatePasswordView: UIView!
    @IBOutlet weak var updatePhoneNumberView: UIView!
    var updateType: UpdateType!
    var activeTextField: UITextField!
    var alertDelegate: AlertDelegate!
     @IBOutlet var arrButtons: [UIButton]!
    override func viewDidLoad() {
        super.viewDidLoad()

        let overlayView = UIView(frame: view!.frame)
        overlayView.backgroundColor = UIColor.black
        overlayView.alpha = 0.8
        view!.addSubview(overlayView)
        self.view.sendSubviewToBack(overlayView)
        self.setUpUI()
    }
    //MARK: Set Up UI
    func setUpUI(){
        self.addTapGesture()
        for vw in self.arrUpdateViews{
            vw.isHidden = true
            vw.layer.cornerRadius = 5.0
            vw.layer.masksToBounds = true
        }
        for btn in self.arrButtons{
            btn.layer.cornerRadius = 6.0
            btn.layer.masksToBounds = true
        }
        switch updateType! {
        case UpdateType.updatePassword:
            updatePasswordView.isHidden = false
        case UpdateType.updatePhoneNumber:
            updatePhoneNumberView.isHidden = false
        }
        
        
    }
    //MARK: UIButton Actions
    @IBAction func togglePasswordAction(_ sender: UIButton){
        sender.isSelected = !sender.isSelected
        let txtField = sender.tag == 1 ? txtCurrentPassword : sender.tag == 2 ? txtNewPassword : txtConfirmPassword
        if sender.isSelected {
            txtField!.isSecureTextEntry = false
        }
        else{
            txtField!.isSecureTextEntry = true
        }
    }
    @IBAction func actionClose(_ sender: UIButton){
        self.dismiss(animated: false) {
        }
    }
    @IBAction func openCountryPickerAction(_ sender: AnyObject) {
        activeTextField = sender.tag == 1 ? txtCurrentCode : txtNewCode
        let picker = ADCountryPicker(style: .grouped)
        picker.delegate = self
        picker.showCallingCodes = true
        picker.didSelectCountryClosure = { name, code in
            _ = picker.navigationController?.popToRootViewController(animated: true)
           
            print(code)
        }
        let pickerNavigationController = UINavigationController(rootViewController: picker)
        self.present(pickerNavigationController, animated: true, completion: nil)
        
    }
    @IBAction func actionUpdatePhone(_ sender: UIButton){
       
       let user = Auth.auth().currentUser
        let currentPh = "\(txtCurrentCode.text!)\(txtCurrentPhone.text!)"
        let newPh = "\(txtNewCode.text!)\(txtNewPhone.text!)"
        if txtCurrentPhone.text == "" || txtNewPhone.text == "" || txtCurrentCode.text == "" || txtNewCode.text == ""{
            self.showAlert(message: "All fields are mandatory")
        }
        else if currentPh != user!.phoneNumber!{
             self.showAlert(message: "Incorrect current phone number")
        }
        else if currentPh == newPh{
            self.showAlert(message: "Please enter a new phone number")
        }
        else if txtNewPhone.text!.isPhoneNumber{
             MBProgressHUD.showAdded(to: self.view, animated: true)
             PhoneAuthProvider.provider().verifyPhoneNumber(newPh, uiDelegate: nil) { (verificationID, error) in
                if error != nil {
                    MBProgressHUD.hide(for: self.view, animated: true)
                    self.showAlert(message: "\(error!.localizedDescription)")
                    return
                }
                else{
                    MBProgressHUD.hide(for: self.view, animated: true)
                    let otpVC = self.storyboard?.instantiateViewController(withIdentifier: "OTPViewController") as! OTPViewController
                    otpVC.signInDelegate = self
                    otpVC.isToUpdate = true
                    otpVC.verificationId = verificationID
                    otpVC.enteredPhoneNumber = newPh
                    self.present(otpVC, animated: true, completion: nil)
                   
                }
            }
        }
        else{
            self.showAlert(message: "Please enter a valid phone number to update")
        }
    }
    @IBAction func actionUpdatePassword(_ sender: UIButton){
        view.endEditing(true)
        if txtCurrentPassword.text == "" || txtNewPassword.text == "" || txtConfirmPassword.text == ""{
            self.showAlert(message: "All fields are mandatory")
        }
        else if txtNewPassword.text!.count < 6{
            self.showAlert(message: "Password should be minimum 6 characters")
        }
        else if txtNewPassword.text != txtConfirmPassword.text{
            self.showAlert(message: "Password mismatch")
        }
        else{
             MBProgressHUD.showAdded(to: self.view, animated: true)
            sender.isEnabled = false
            let user = Auth.auth().currentUser
            let credential = EmailAuthProvider.credential(withEmail: user!.email!, password: txtCurrentPassword.text!)
            // Prompt the user to re-provide their sign-in credentials
            
            user?.reauthenticate(with: credential, completion: { (result, error) in
                if (error != nil){
                     MBProgressHUD.hide(for: self.view, animated: true)
                   // self.showAlert(message: error!.localizedDescription)
                    let alert = UIAlertController(title: error!.localizedDescription, message: "", preferredStyle: .alert)
                    
                    let okAction = UIAlertAction(title: "Ok", style: .default, handler: { (action) in
                        sender.isEnabled = true
                    })
                    alert.addAction(okAction)
                    
                    self.present(alert, animated: true, completion: nil)
                    return
                }
               Auth.auth().currentUser?.updatePassword(to: self.txtNewPassword.text!, completion: { (error) in
                 MBProgressHUD.hide(for: self.view, animated: true)
                    if (error != nil){
                        let alert = UIAlertController(title: error!.localizedDescription, message: "", preferredStyle: .alert)
                        
                        let okAction = UIAlertAction(title: "Ok", style: .default, handler: { (action) in
                            sender.isEnabled = true
                        })
                        alert.addAction(okAction)
                        
                        self.present(alert, animated: true, completion: nil)
                        return
                    }
                    let alert = UIAlertController(title: "Password updated succesfully", message: "", preferredStyle: .alert)
                    
                    let okAction = UIAlertAction(title: "Ok", style: .default, handler: { (action) in
                        self.dismiss(animated: true, completion: nil)
                         sender.isEnabled = true
                    })
                    alert.addAction(okAction)
                    
                    self.present(alert, animated: true, completion: nil)
                    
                    
                    
                    
                })
            })
        }
    }
  

}
extension UpdateDetailsViewController: ADCountryPickerDelegate {
    
    func countryPicker(_ picker: ADCountryPicker, didSelectCountryWithName name: String, code: String, dialCode: String) {
        _ = picker.navigationController?.popToRootViewController(animated: true)
        self.dismiss(animated: true, completion: nil)
        self.activeTextField.text = dialCode
        
      
    }
}
extension UpdateDetailsViewController: SignInDelegate{
    func signInUser() {
        self.dismiss(animated: false, completion: nil)
    }
}
extension UpdateDetailsViewController: UITextFieldDelegate{
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

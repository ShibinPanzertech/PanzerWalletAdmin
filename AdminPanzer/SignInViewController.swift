//
//  SignInViewController.swift
//  AdminPanzer
//
//  Created by Panzer Tech Pte Ltd on 17/12/19.
//  Copyright © 2019 test.com. All rights reserved.
//

import UIKit
import Firebase

var isSignedIn = false
var isNoNetAlertShown = false
var isSessionTimeoutAlertShown = false
class SignInViewController: UIViewController {
    var verificationId: String!
    @IBOutlet weak var btnLogin: MBSliderView!
    @IBOutlet weak var txtPassword: UITextField!
    @IBOutlet weak var txtEmail: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.isNavigationBarHidden = true
        self.setUpUI()
       
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        txtEmail.text = ""
        txtPassword.text = ""
    }
    //MARK: Add Firebase User
    func addUser(){
  /*
         Auth.auth().createUser(withEmail: "tlthushara90@gmail.com", password: "123456") { authResult, error in
        if error == nil{
            
            PhoneAuthProvider.provider().verifyPhoneNumber("+919645500089", uiDelegate: nil) { (verificationID, error) in
                if error != nil {
    
                    return
                }
                self.verificationId = verificationID
    
                let otpVC = self.storyboard?.instantiateViewController(withIdentifier: "OTPViewController") as! OTPViewController
                otpVC.verificationId = verificationID
                self.present(otpVC, animated: true, completion: nil)
   
                }
            }
        }
 */
    }
    //MARK: setUpUI
    func setUpUI(){
        self.addTapGesture()
        btnLogin.delegate = self
        btnLogin.backgroundColor = self.hexStringToUIColor(hex: "2D6FCA")
        btnLogin.layer.cornerRadius = 25.0
        btnLogin.layer.masksToBounds = true
    }
    //MARK: UIButton Action
    @IBAction func togglePasswordAction(_ sender: UIButton){
        sender.isSelected = !sender.isSelected
        if sender.isSelected {
            txtPassword.isSecureTextEntry = false
        }
        else{
            txtPassword.isSecureTextEntry = true
        }
    }
   
    @IBAction func actionForgotPassword(_ sender: UIButton){
        let resetVC = self.storyboard?.instantiateViewController(withIdentifier: "ResetPasswordViewController") as! ResetPasswordViewController
        self.navigationController?.pushViewController(resetVC, animated: true)
    }
     func actionLogin(){
       
        if txtEmail.text == ""{
            self.showAlert(message: "Please enter email id")
        }
        else if txtPassword.text == ""{
            self.showAlert(message: "Please enter password")
        }
        else if !isValidEmail(emailStr: txtEmail.text!){
            self.showAlert(message: "Please enter a valid email id")
        }
        else{
            MBProgressHUD.showAdded(to: self.view, animated: true)
            Auth.auth().signIn(withEmail: txtEmail.text!, password: txtPassword.text!) { [weak self] authResult, error in
                
               
                if error == nil{
                    
                   
                    let user = Auth.auth().currentUser
                    MBProgressHUD.hide(for: self!.view, animated: true)
                   self?.signInUser()
               
                  /*
                    if (user!.phoneNumber != nil){
                    PhoneAuthProvider.provider().verifyPhoneNumber(user!.phoneNumber!, uiDelegate: nil) { (verificationID, error) in
                        
                        if error != nil {
                            
                             MBProgressHUD.hide(for: self!.view, animated: true)
                            self!.showAlert(message: "\(error!.localizedDescription)")
                            return
                        
                        }
                        MBProgressHUD.hide(for: self!.view, animated: true)
                       self!.verificationId = verificationID
                        
                        let otpVC = self?.storyboard?.instantiateViewController(withIdentifier: "OTPViewController") as! OTPViewController
                        otpVC.signInDelegate = self
                        otpVC.verificationId = verificationID
                        self!.present(otpVC, animated: true, completion: nil)
                     
                        }
                    }
                    else if user!.email == "apple@panzertech.com"{
                        MBProgressHUD.hide(for: self!.view, animated: true)
                        self?.signInUser()
                    }
                    else{
                         MBProgressHUD.hide(for: self!.view, animated: true)
                    }
                  // */
                }
                else {
                     MBProgressHUD.hide(for: self!.view, animated: true)
                    self!.showAlert(message: "\(error!.localizedDescription)")
                }
            }
        }
    }
   
}
extension SignInViewController: UITextFieldDelegate{
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
extension SignInViewController: MBSliderViewDelegate{
    func sliderDidSlide(_ slideView: MBSliderView!) {
        self.view.endEditing(true)
        self.actionLogin()
    }
    
    
}
extension SignInViewController: SignInDelegate{
    func signInUser() {
        let homeVC = self.storyboard?.instantiateViewController(withIdentifier: "HomeViewController") as! HomeViewController
        self.navigationController?.pushViewController(homeVC, animated: true)
    }
  
    
}
extension UIViewController{
    
    func addTapGesture(){
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.hideKeyboard(_:)))
        tapGesture.numberOfTapsRequired = 1
        self.view.addGestureRecognizer(tapGesture)
    }
    @objc func hideKeyboard(_ sender: UITapGestureRecognizer) {
        self.view.endEditing(true)
    }
    func isValidPhone(value: String) -> Bool {
        let PHONE_REGEX = "^\\d{3}-\\d{3}-\\d{4}$"
        let phoneTest = NSPredicate(format: "SELF MATCHES %@", PHONE_REGEX)
        let result =  phoneTest.evaluate(with: value)
        return result
    }
    func isValidEmail(emailStr:String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        
        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: emailStr)
    }
    func showAlert(message: String){
        let alert = UIAlertController(title: message, message: "", preferredStyle: .alert)
        
        let okAction = UIAlertAction(title: "Ok", style: .default, handler: { (action) in
            
        })
        alert.addAction(okAction)
      self.present(alert, animated: true, completion: nil)
        
    }
    func showSessionTimeOut(){
        isSessionTimeoutAlertShown = true
        let alert = UIAlertController(title: "Your session has expired", message: "", preferredStyle: .alert)
        
        let okAction = UIAlertAction(title: "Ok", style: .default, handler: { (action) in
            isSessionTimeoutAlertShown = false
           let appDelegate = UIApplication.shared.delegate as! AppDelegate
            appDelegate.setLogin()
            
        })
        alert.addAction(okAction)
        if let topController = UIApplication.topViewController() {
            topController.view.endEditing(true)
            topController.present(alert, animated: true, completion: nil)
        }
        else{
            self.present(alert, animated: true, completion: nil)
        }
        
    }
    func networkConnected(){
        if isNoNetAlertShown == true{
        isNoNetAlertShown = false
       self.dismiss(animated: true, completion: nil)
        }
    }
    func showNoNetwork(){
        isNoNetAlertShown = true
        let alert = UIAlertController(title: "Please connect to internet", message: "", preferredStyle: .alert)
        
        let okAction = UIAlertAction(title: "Ok", style: .default, handler: { (action) in
            isNoNetAlertShown = false
            
        })
        alert.addAction(okAction)
        if let topController = UIApplication.topViewController() {
            topController.view.endEditing(true)
            topController.present(alert, animated: true, completion: nil)
        }
        else{
            self.present(alert, animated: true, completion: nil)
        }
        
    }
    func hexStringToUIColor (hex:String) -> UIColor {
        var cString:String = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        
        if (cString.hasPrefix("#")) {
            cString.remove(at: cString.startIndex)
        }
        
        if ((cString.count) != 6) {
            return UIColor.gray
        }
        
        var rgbValue:UInt64 = 0
        Scanner(string: cString).scanHexInt64(&rgbValue)
        
        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }
}

extension String {
    var isPhoneNumber: Bool {
        do {
            let detector = try NSDataDetector(types: NSTextCheckingResult.CheckingType.phoneNumber.rawValue)
            let matches = detector.matches(in: self, options: .reportCompletion, range: NSMakeRange(0, self.count))
            if let res = matches.first {
                return res.resultType == .phoneNumber && res.range.location == 0 && res.range.length == self.count
            } else {
                return false
            }
        } catch {
            return false
        }
    }
}
extension UIApplication {
    class func topViewController(controller: UIViewController? = UIApplication.shared.keyWindow?.rootViewController) -> UIViewController? {
        if let navigationController = controller as? UINavigationController {
            return topViewController(controller: navigationController.visibleViewController)
        }
        if let tabController = controller as? UITabBarController {
            if let selected = tabController.selectedViewController {
                return topViewController(controller: selected)
            }
        }
        if let presented = controller?.presentedViewController {
            return topViewController(controller: presented)
        }
        return controller
}
}

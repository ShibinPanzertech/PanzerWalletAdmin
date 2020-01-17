//
//  OTPViewController.swift
//  AdminPanzer
//
//  Created by Panzer Tech Pte Ltd on 26/12/19.
//  Copyright © 2019 test.com. All rights reserved.
//

import UIKit
import Firebase
import Alamofire

protocol SignInDelegate {
    func signInUser()
}
class OTPViewController: UIViewController {
    @IBOutlet weak var otpView: VPMOTPView!
    @IBOutlet weak var btnSubmit: UIButton!
     @IBOutlet weak var btnResend: UIButton!
    @IBOutlet weak var lblOtpMessage: UILabel!
    var enteredOtp: String = ""
    var verificationId: String!
    var enteredPhoneNumber: String!
    var isToUpdate: Bool?
    var signInDelegate: SignInDelegate!
    var activateTimer: Timer?
    override func viewDidLoad() {
        super.viewDidLoad()
        if let user  = Auth.auth().currentUser {
            user.getIDToken(completion: { (authuser, error) in
                if error != nil {
                    return
                }
            })
            
        }
        btnResend.isEnabled = false
          btnResend.alpha = 0.5
        activateResendButton()
        if Auth.auth().currentUser!.phoneNumber != nil{
        let phNo =   self.isToUpdate == nil ? Auth.auth().currentUser!.phoneNumber!.suffix(2) : enteredPhoneNumber!.suffix(2)
        let message = "Please enter the verification code sent to ********\(phNo)"
        self.lblOtpMessage.text = message
        }
        
        self.addTapGesture()
        otpView.otpFieldDisplayType = .square
        otpView.otpFieldsCount = 6
        otpView.otpFieldDefaultBorderColor = UIColor.black
        otpView.otpFieldEnteredBorderColor = UIColor(red: 45/255, green: 111/255, blue: 202/255, alpha: 1.0)
        otpView.otpFieldErrorBorderColor = UIColor.red
        otpView.otpFieldBorderWidth = 2
        otpView.delegate = self
        otpView.shouldAllowIntermediateEditing = false
        
        // Create the UI
        otpView.initializeUI()

    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if let _ = activateTimer {
            activateTimer!.invalidate()
        }
    }
    func activateResendButton(){
        if let _ = activateTimer {
            activateTimer!.invalidate()
        }
        
        activateTimer = Timer.scheduledTimer(timeInterval: 60,
                                         target: self,
                                         selector: #selector(OTPViewController.activate),
                                         userInfo: nil,
                                         repeats: false
        )
    }
    @objc func activate(){
        btnResend.isEnabled  = true
          btnResend.alpha = 1.0
        if let _ = activateTimer {
            activateTimer!.invalidate()
        }
    }
    //MARK: setUpUI
    func setUpUI(){
        self.addTapGesture()
        btnSubmit.layer.cornerRadius = 25.0
        btnSubmit.layer.masksToBounds = true
    }
    @IBAction func actionBack(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    @IBAction func actionValidateOtp(_ sender: UIButton) {
       
            btnResend.isEnabled  = false
            btnResend.alpha = 0.5
            activateResendButton()
        
         if self.isToUpdate == nil{
            MBProgressHUD.showAdded(to: self.view, animated: true)
            let credential = PhoneAuthProvider.provider().credential(
            withVerificationID: self.verificationId,
            verificationCode: enteredOtp)
            let user = Auth.auth().currentUser
            user?.reauthenticate(with: credential, completion: { (authResult, error) in
                 MBProgressHUD.hide(for: self.view, animated: true)
                if let error = error {
                    self.otpView.clearText()
                    self.showAlert(message: error.localizedDescription)
                    return
                }
                
                // User is signed in
                if self.signInDelegate != nil{
                    self.dismiss(animated: true, completion: {
                        self.signInDelegate.signInUser()
                    })
                    
                }
            })
            
            
    
           
        }
        else{
            MBProgressHUD.showAdded(to: self.view, animated: true)
            let credential = PhoneAuthProvider.provider().credential(
                withVerificationID: self.verificationId,
                verificationCode: enteredOtp)
            Auth.auth().currentUser?.updatePhoneNumber(credential, completion: { (error) in
                
                 MBProgressHUD.hide(for: self.view, animated: true)
                if error != nil{
                    self.otpView.clearText()
                    self.showAlert(message: error!.localizedDescription)
                    return
                }
                let alert = UIAlertController(title: "Phone number updated succesfully", message: "", preferredStyle: .alert)
                
                let okAction = UIAlertAction(title: "Ok", style: .default, handler: { (action) in
                   
                    self.dismiss(animated: false, completion: {
                         self.signInDelegate.signInUser()
                    })
                })
                alert.addAction(okAction)
                
                self.present(alert, animated: true, completion: nil)
            })
        }
 
      
      /*  Auth.auth().currentUser!.link(with: credential) { (authResult, error) in
            if error != nil{
                self.showAlert(message: error!.localizedDescription)
                return
            }
            let homeVC = self.storyboard?.instantiateViewController(withIdentifier: "HomeViewController") as! HomeViewController
            self.navigationController?.pushViewController(homeVC, animated: true)
        }
        */
 
    }
    @IBAction func actionResendOtp(_ sender: UIButton) {
        btnResend.isEnabled  = false
         btnResend.alpha = 0.5
        activateResendButton()
        
       
        let user = Auth.auth().currentUser
        
       

        
        let phNo =   self.isToUpdate == nil ? user!.phoneNumber! : enteredPhoneNumber

        if (user!.phoneNumber != nil){
           
            PhoneAuthProvider.provider(auth: Auth.auth()).verifyPhoneNumber(phNo!, uiDelegate: nil) { (verificationID, error) in
                if error != nil {
                    self.showAlert(message: "\(error!.localizedDescription)")
                    return
                }
                self.verificationId = verificationID
            }
            
        }
    }

}
extension OTPViewController: VPMOTPViewDelegate {
    func hasEnteredAllOTP(hasEntered: Bool) -> Bool {
        print("Has entered all OTP? \(hasEntered)")
        
        return true//enteredOtp == "123456"
    }
    
    func shouldBecomeFirstResponderForOTP(otpFieldIndex index: Int) -> Bool {
        return true
    }
    
    func enteredOTP(otpString: String) {
        enteredOtp = otpString
        print("OTPString: \(otpString)")
        self.actionValidateOtp(UIButton())
       
    }
}
class NetworkStatus {
    static let sharedInstance = NetworkStatus()
    
    private init() {}
    
    let reachabilityManager = Alamofire.NetworkReachabilityManager(host: "www.apple.com")
    
    func startNetworkReachabilityObserver() {
        reachabilityManager?.startListening(onUpdatePerforming: { (status) in
            
            switch status {
                
            case .reachable(.ethernetOrWiFi):
                print("The network is reachable over the WiFi connection")
                if isNoNetAlertShown == true{
                    if let topController = UIApplication.topViewController() {
                        topController.networkConnected()
                    }
                }
            case .notReachable:
                print("The network is not reachable")
                if let topController = UIApplication.topViewController() {
                    topController.showNoNetwork()
                }
            case .unknown :
                print("It is unknown whether the network is reachable")
                
            case .reachable(.cellular):
                print("It is cellular")
            }
        })
    }
}

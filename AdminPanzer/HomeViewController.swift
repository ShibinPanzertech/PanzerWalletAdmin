//
//  HomeViewController.swift
//  AdminPanzer
//
//  Created by Panzer Tech Pte Ltd on 17/12/19.
//  Copyright © 2019 test.com. All rights reserved.
//

import UIKit
import Firebase
class HomeViewController: UIViewController {
  
    @IBOutlet weak var tblWallets: UITableView!
    // UntrackedWalletsDetails
    var untrackedWallets = Array<[String:String]>()
   // SavedWalletsDetails
var walletsDetails = Array<[String:Any]>()
    override func viewDidLoad() {
        super.viewDidLoad()

        isSignedIn = true
        
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let sharedDefaults = UserDefaults(suiteName: "group.com.adminpanzerwallet.savedkeys")
        let walletAddress = sharedDefaults?.value(forKey: "SavedWalletsDetails") as? Array<[String:Any]>
        untrackedWallets = sharedDefaults?.value(forKey: "UntrackedWallets") as? Array<[String:String]> ?? Array<[String:String]>()
        
        
        
        if walletAddress != nil{
            self.tblWallets.reloadData()
           // let walletsArr = walletAddress?.removingDuplicates()
           /* if walletsArr != nil{
                print(walletsArr!)
                self.wallets = walletsArr!
                self.tblWallets.reloadData()
            }*/
        }
        else{
            self.showAlert(message: "No Private keys found")
        }
        if sharedDefaults?.value(forKey: "SavedWalletsDetails") != nil{
            self.walletsDetails = (sharedDefaults?.value(forKey: "SavedWalletsDetails") as! Array<[String:Any]>)
            self.walletsDetails = (self.walletsDetails as NSArray).sortedArray(using: [NSSortDescriptor(key: "Name", ascending: true)]) as! [[String:AnyObject]]

        print("...............")
        print(self.walletsDetails)
        print("...............")
        }
    }
    //MARK: UIButton Action
    @IBAction func actionSettings(sender: UIButton){
        let settingsVC = self.storyboard?.instantiateViewController(withIdentifier: "SettingsViewController") as! SettingsViewController
        self.navigationController?.pushViewController(settingsVC, animated: true)
    }
   
  @objc  @IBAction func actionCopyWalletAddress(_ sender: UIButton){
    guard let cell = sender.superview?.superview?.superview as? WalletDetailsTableViewCell else {
        return // or fatalError() or whatever
    }
    
    let indexPath = tblWallets.indexPath(for: cell)
    if indexPath!.section < walletsDetails.count{
        let walletData = self.walletsDetails[indexPath!.section]["Wallets"] as! Array<[String : String]>
        let walletDict = walletData[indexPath!.row]
        UIPasteboard.general.string = walletDict["WalletAddress"]
        self.showAlert(message: "Copied to clipboard")
        
        
       
    }
    else{
        let walletDict = untrackedWallets[indexPath!.row]
        UIPasteboard.general.string = walletDict["WalletAddress"]
        self.showAlert(message: "Copied to clipboard")
    }
    }
   @objc @IBAction func actionCopyWalletKey(_ sender: UIButton){
    guard let cell = sender.superview?.superview?.superview as? WalletDetailsTableViewCell else {
        return // or fatalError() or whatever
    }
    let indexPath = tblWallets.indexPath(for: cell)
    if indexPath!.section < walletsDetails.count{
        let walletData = self.walletsDetails[indexPath!.section]["Wallets"] as! Array<[String : String]>
        let walletDict = walletData[indexPath!.row]
        //let walletDict = wallets[sender.tag]
        UIPasteboard.general.string = walletDict["WalletPrivateKey"]
        //   print(walletDict["WalletPrivateKey"])
        self.showAlert(message: "Copied to clipboard")
        
        
    }
    else{
        let walletDict = untrackedWallets[indexPath!.row]
        UIPasteboard.general.string = walletDict["WalletPrivateKey"]
        self.showAlert(message: "Copied to clipboard")
    }
    }
}
extension HomeViewController: UITableViewDataSource, UITableViewDelegate{
    func numberOfSections(in tableView: UITableView) -> Int {
        
        let secno = self.walletsDetails.count + (untrackedWallets.count == 0 ? 0 : 1)
        print(":::::: \(secno)")
        return secno
        //return 1
    }
 /*   func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return wallets.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
         let cell:WalletDetailsTableViewCell = tableView.dequeueReusableCell(withIdentifier: "Cell") as! WalletDetailsTableViewCell
        let walletDict = wallets[indexPath.row]
        cell.lblWalletName.text = walletDict["WalletName"]
        cell.lblWalletAddress.text = walletDict["WalletAddress"]
        cell.lblWalletPrivateKey.text = walletDict["WalletPrivateKey"]
        cell.lblEmail.text = walletDict["email"]
        cell.vwContainer.dropShadow()
        cell.btnCopyWalletAddress.tag = indexPath.row
        cell.btnCopyWalletPrivateKey.tag = indexPath.row
        cell.btnCopyWalletAddress.addTarget(self, action: #selector(actionCopyWalletAddress(_:)), for: .touchUpInside)
        cell.btnCopyWalletPrivateKey.addTarget(self, action: #selector(actionCopyWalletKey(_:)), for: .touchUpInside)
        return cell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 235
        
    }*/
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var walletData = Array<[String : String]>()
        if section < walletsDetails.count{
            walletData = self.walletsDetails[section]["Wallets"] as! Array<[String : String]>
        }
        return section < walletsDetails.count ?  walletData.count : untrackedWallets.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
       
        let cell:WalletDetailsTableViewCell = tableView.dequeueReusableCell(withIdentifier: "WalletCell") as! WalletDetailsTableViewCell
        if indexPath.section < walletsDetails.count{
            let walletData = self.walletsDetails[indexPath.section]["Wallets"] as! Array<[String : String]>
            let walletDict = walletData[indexPath.row]
            cell.lblWalletName.text = walletDict["WalletName"]
            cell.lblWalletAddress.text = walletDict["WalletAddress"]
            cell.lblWalletPrivateKey.text = walletDict["WalletPrivateKey"]
            cell.vwContainer.dropShadow()
            cell.btnCopyWalletAddress.tag = indexPath.section + indexPath.row
            cell.btnCopyWalletPrivateKey.tag = indexPath.section + indexPath.row
            cell.btnCopyWalletAddress.addTarget(self, action: #selector(actionCopyWalletAddress(_:)), for: .touchUpInside)
            cell.btnCopyWalletPrivateKey.addTarget(self, action: #selector(actionCopyWalletKey(_:)), for: .touchUpInside)
            return cell
            
            
          
        }
        else{
        
            let walletDict = untrackedWallets[indexPath.row]
            cell.lblWalletName.text = walletDict["WalletName"]
            cell.lblWalletAddress.text = walletDict["WalletAddress"]
            cell.lblWalletPrivateKey.text = walletDict["WalletPrivateKey"]
            cell.vwContainer.dropShadow()
            cell.btnCopyWalletAddress.tag = indexPath.section + indexPath.row
            cell.btnCopyWalletPrivateKey.tag = indexPath.section + indexPath.row
            cell.btnCopyWalletAddress.addTarget(self, action: #selector(actionCopyWalletAddress(_:)), for: .touchUpInside)
            cell.btnCopyWalletPrivateKey.addTarget(self, action: #selector(actionCopyWalletKey(_:)), for: .touchUpInside)
            return cell
        }
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 200
        
    }
  
     func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section < walletsDetails.count{
            let headerCell = tableView.dequeueReusableCell(withIdentifier: "HeaderCell") as! WalletHeaderTableViewCell
            let walletData = self.walletsDetails[section]
            headerCell.lblName.text  = walletData["Name"] as? String
            headerCell.lblEmail.text = walletData["Email"] as? String
            return headerCell
            
            
          
        }
        else{
            let headerCell = tableView.dequeueReusableCell(withIdentifier: "HeaderCell") as! WalletHeaderTableViewCell
            headerCell.lblHeading.text  = "UNTRACKED WALLETS"
            return headerCell
        }
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 65
    }
}
extension UIView {
    
    func dropShadow() {
/*  self.layer.cornerRadius = 5.0
        self.layer.masksToBounds = true
        
       self.layer.masksToBounds = false
        self.layer.shadowColor = UIColor.lightGray.cgColor
        self.layer.shadowOpacity = 0.5
        self.layer.shadowOffset = CGSize(width: -1, height: 1)
        self.layer.shadowRadius = 1
        self.layer.shadowPath = UIBezierPath(rect: self.bounds).cgPath
       // self.layer.shouldRasterize = true
      //  self.layer.rasterizationScale = UIScreen.main.scale
 */
        layer.shadowColor = UIColor.lightGray.cgColor
        layer.shadowOffset = CGSize(width: 0, height: 1)
        layer.shadowOpacity = 1.0
        layer.shadowRadius = 1
        clipsToBounds = false
        
    }
}

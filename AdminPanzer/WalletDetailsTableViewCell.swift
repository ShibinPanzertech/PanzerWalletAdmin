//
//  WalletDetailsTableViewCell.swift
//  AdminPanzer
//
//  Created by Panzer Tech Pte Ltd on 17/12/19.
//  Copyright © 2019 test.com. All rights reserved.
//

import UIKit

class WalletDetailsTableViewCell: UITableViewCell {
    @IBOutlet weak var vwContainer: UIView!
     @IBOutlet weak var lblEmail: UILabel!
    @IBOutlet weak var lblWalletName: UILabel!
    @IBOutlet weak var lblWalletAddress: UILabel!
    @IBOutlet weak var lblWalletPrivateKey: UILabel!
    @IBOutlet weak var btnCopyWalletPrivateKey: UIButton!
    @IBOutlet weak var btnCopyWalletAddress: UIButton!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

class WalletHeaderTableViewCell: UITableViewCell {
    @IBOutlet weak var vwContainer: UIView!
    @IBOutlet weak var lblHeading: UILabel!
    @IBOutlet weak var lblEmail: UILabel!
    @IBOutlet weak var lblName: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}

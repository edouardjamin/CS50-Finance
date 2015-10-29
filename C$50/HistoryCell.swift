//
//  HistoryCell.swift
//  C$50
//
//  Created by Edouard Jamin on 13/08/15.
//  Copyright © 2015 Gobu. All rights reserved.
//

import UIKit

class HistoryCell: UITableViewCell {
    
    @IBOutlet weak var numberLabel: UILabel!
    
    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var typeLabel: UILabel!
    

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

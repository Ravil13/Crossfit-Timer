//
//  PickerCell.swift
//  Crossfit Timer
//
//  Created by Равиль Вильданов on 29.06.2018.
//  Copyright © 2018 Равиль Вильданов. All rights reserved.
//

import UIKit

class PickerCell: UITableViewCell {
    
    @IBOutlet weak var timePicker: UIPickerView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
}

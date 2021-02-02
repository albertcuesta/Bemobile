//
//  TransaccionesTableViewCell.swift
//  Bemobile
//
//  Created by Albert on 31/01/2021.
//  Copyright © 2021 Albert. All rights reserved.
//

import UIKit

class TransaccionesTableViewCell: UITableViewCell {

    @IBOutlet var skuLabelCell: UILabel!
    @IBOutlet var amountLabelCell: UILabel!
    @IBOutlet var currencyLabelCell: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

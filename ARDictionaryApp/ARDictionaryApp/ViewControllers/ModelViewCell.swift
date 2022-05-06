//
//  ModelViewCell.swift
//  ARDictionaryApp
//
//  Created by Tom on 2019/12/16.
//  Copyright © 2019 Dgene. All rights reserved.
//

import UIKit

class ModelViewCell: UITableViewCell {

    @IBOutlet weak var imgView: UIImageView!
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

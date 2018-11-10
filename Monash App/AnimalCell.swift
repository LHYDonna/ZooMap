//
//  AnimalCell.swift
//  Monash App
//
//  Created by 林洪钰 on 23/8/18.
//  Copyright © 2018 林洪钰. All rights reserved.
//

import UIKit

class AnimalCell: UITableViewCell {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var descLabel: UILabel!
    @IBOutlet weak var pinImage: UIImageView!
    @IBOutlet weak var addressLabel: UITextView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

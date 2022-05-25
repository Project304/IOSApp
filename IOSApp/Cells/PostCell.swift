//
//  PostViewCell.swift
//  Project304IOSApp
//
//  Created by berkay on 5/17/22.
//

import UIKit

class PostCell: UITableViewCell {
    
    
    @IBOutlet weak var postImage: UIImageView!
    @IBOutlet weak var likesLabel: UILabel!
    @IBOutlet weak var userComment: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}


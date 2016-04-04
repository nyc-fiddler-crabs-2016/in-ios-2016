//
//  ConversationTableViewCell.swift
//  In
//
//  Created by Apprentice on 4/4/16.
//  Copyright © 2016 Ryan F. Salerno. All rights reserved.
//

import UIKit

class ConversationTableViewCell: UITableViewCell {
    
    //MARK: Properties
    
    @IBOutlet weak var conversationLabel: UILabel!
    
    @IBOutlet weak var participantLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

//
//  ConversationTableCellController.swift
//  In
//
//  Created by Apprentice on 4/3/16.
//  Copyright © 2016 Ryan F. Salerno. All rights reserved.
//

import UIKit

class ConversationTableCellController: UITableViewCell {
    
    //MARK: Properties

    @IBOutlet weak var conversationImageLabel: UIView!
    @IBOutlet weak var conversationLabel: UIView!
    

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

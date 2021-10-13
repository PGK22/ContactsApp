//
//  ContactViewCell.swift
//  FetchContact
//
//  Created by Palak on 09/10/21.
//

import UIKit

class ContactViewCell: UITableViewCell {

    @IBOutlet weak var telephonehandler: UILabel!
    
    @IBOutlet weak var namehandler: UILabel!
    
    

    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}

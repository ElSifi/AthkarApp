//
//  HomeSectionTableViewCell.swift
//  DailyAthkar
//
//  Created by Mohamed ElSIfi on 4/27/18.
//  Copyright © 2018 Badi3.com. All rights reserved.
//

import UIKit
import SwipeCellKit

class HomeSectionTableViewCell: SwipeTableViewCell {

    var data: AthkarSection?{
        didSet{
            if let theData = data{
                self.titleLabel.text = theData.localizedName()
            }
        }
    }
    @IBOutlet weak var iconContainer: UIView!{
        didSet{
            iconContainer.layer.borderColor = UIColor.white.cgColor
            iconContainer.layer.borderWidth = 1.5
            iconContainer.clipsToBounds = true
        }
    }
    
    
    @IBOutlet weak var bgView: UIView!{
        didSet{
            bgView.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        }
    }
    @IBOutlet weak var iconImage: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!{
        didSet{
            titleLabel.font = DA_STYLE.menuFont
        }
    }
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    

    override func setSelected(_ selected: Bool, animated: Bool) {
        //super.setSelected(selected, animated: animated)

        
    }
    
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        UIView.animate(withDuration: 0.15) {
            self.bgView.backgroundColor = UIColor.black.withAlphaComponent(highlighted ? 0.75 : 0.6)
        }

    }

}

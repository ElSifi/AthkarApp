//
//  ThikrTableViewCell.swift
//  DailyAthkar
//
//  Created by Mohamed ElSIfi on 5/1/18.
//  Copyright © 2018 Badi3.com. All rights reserved.
//

import UIKit
import SwipeCellKit

protocol ThikrTableViewCellDelegate : class {
    func playSoundOfThikrViewModel(thikrViewModel : ThikrCellViewModel)
}

class ThikrTableViewCell: SwipeTableViewCell {

    weak var athkarDelegate : ThikrTableViewCellDelegate?
    @IBOutlet weak var leftRepeatLabel: UILabel!
    @IBOutlet weak var middleRepeatLabel: UILabel!
    @IBOutlet weak var rightRepeatLabel: UILabel!
    @IBOutlet weak var soundIcon: UIImageView!
    var data :ThikrCellViewModel?{
        didSet{
            guard let data = data else{
                return
            }
            self.textContent.text = data.localizedText()
            
        }
    }
    @IBOutlet weak var bgView: UIView!
    @IBOutlet weak var textContent: UILabel!{
        didSet{
            textContent.font = DA_STYLE.savedFont
        }
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {

        // Configure the view for the selected state
    }
    
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        UIView.animate(withDuration: 0.15) {
            self.bgView.backgroundColor = UIColor.black.withAlphaComponent(highlighted ? 0.55 : 0.35)
        }
    }
    let animationImages : [UIImage] = [
        #imageLiteral(resourceName: "soundPlaying_0"),
        #imageLiteral(resourceName: "soundPlaying_1"),
        #imageLiteral(resourceName: "soundPlaying_2"),
        #imageLiteral(resourceName: "soundPlaying_3"),
        #imageLiteral(resourceName: "soundPlaying_4"),
        #imageLiteral(resourceName: "soundPlaying_5"),
        #imageLiteral(resourceName: "soundPlaying_6")
    ]
    
    var isAudioPlaying : Bool = false{
        didSet{
            print("isAudioPlaying \(isAudioPlaying)")
            if(isAudioPlaying){
                if(!self.soundIcon.isAnimating){
                    self.soundIcon.animationImages = animationImages
                    self.soundIcon.animationDuration = 0.8
                    self.soundIcon.startAnimating()
                }
            }else{
                self.soundIcon.stopAnimating()
                self.soundIcon.image = #imageLiteral(resourceName: "soundPlaying_0")

            }
        }
    }

    @IBAction func soundAction(_ sender: Any) {
        print("soundAction")
        
        if let del = self.athkarDelegate, let data = self.data{
            del.playSoundOfThikrViewModel(thikrViewModel: data)
        }
    }
}

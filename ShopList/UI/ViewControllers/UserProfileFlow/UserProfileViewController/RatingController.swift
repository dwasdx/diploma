import Foundation

import UIKit

protocol RatingViewControllering: AnyObject {
    var starsRating: Int { get set }
}

class RatingController: UIStackView {
    
    weak var delegate: RatingViewControllering?
    var starsRating = 0 {
        didSet {
            delegate?.starsRating = self.starsRating
        }
    }
    var starsEmptyPicName = #imageLiteral(resourceName: "star.empty.gray")
    var starsFilledPicName = #imageLiteral(resourceName: "star.filled.yellow")
    override func draw(_ rect: CGRect) {
        let starButtons = self.subviews.compactMap { $0 as? UIButton }
        var starTag = 1
        starButtons.forEach { (button) in
            button.setImage(starsEmptyPicName, for: .normal)
            button.addTarget(self, action: #selector(self.pressed(sender:)), for: .touchUpInside)
            button.tag = starTag
            starTag += 1
        }
       setStarsRating(rating: starsRating)
    }
    func setStarsRating(rating:Int){
        self.starsRating = rating
        let stackSubViews = self.subviews.compactMap { $0 as? UIButton }
        stackSubViews.forEach { (button) in
            if button.tag > starsRating {
                button.setImage(starsEmptyPicName, for: .normal)
            }else{
                button.setImage(starsFilledPicName, for: .normal)
            }
        }
    }
    @objc func pressed(sender: UIButton) {
        setStarsRating(rating: sender.tag)
    }
}

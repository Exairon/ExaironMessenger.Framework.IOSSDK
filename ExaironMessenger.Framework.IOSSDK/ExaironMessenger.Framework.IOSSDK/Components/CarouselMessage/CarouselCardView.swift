//
//  CarouselCardView.swift
//  ExaironFramework
//
//  Created by Exairon on 24.03.2023.
//

import UIKit
import ScalingCarousel

class CarouselCardView: ScalingCarouselCell {
    
    @IBOutlet weak var cardImage: UIImageView!
    @IBOutlet weak var cardTitle: UILabel!
    @IBOutlet weak var cardDescription: UILabel!
    @IBOutlet weak var cardButtonListView: UIStackView!
    var initial: Bool = false
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func initialView(card: Element) {
        for arrangedView in cardButtonListView.arrangedSubviews {
            cardButtonListView.removeArrangedSubview(arrangedView)
        }
        
        for button in (card.buttons ?? []) {
            let buttonView = ButtonView(frame: CGRect(x: 0, y: 0, width: 0, height: 0), button: button, responseType: "carousel")
            cardButtonListView.addArrangedSubview(buttonView)
        }
        
        mainView.backgroundColor = UIColor(hexString: "#E4E4E7")
        cardButtonListView.backgroundColor = UIColor(hexString: "#E4E4E7")
        cardImage.downloaded(from: card.image_url ?? "")
        cardTitle.text = card.title
        cardDescription.text = card.subtitle
        cardTitle.font = UIFont(name: "OpenSans-Regular", size: cardTitle.font.pointSize)
        cardDescription.font = UIFont(name: "OpenSans-Regular", size: cardDescription.font.pointSize)
    }
    
    func commonInit() {
        let viewFromXib = Bundle(for: Exairon.self).loadNibNamed("CarouselCardView", owner: self, options: nil)![0] as! UIView
        viewFromXib.frame = self.bounds
        addSubview(viewFromXib)
        //initialView()
    }
    
    /*override init(frame: CGRect) {
        super.init(frame: frame)
        mainView = CarouselCard(frame: contentView.bounds, image: "active_1.png")
        contentView.addSubview(mainView)
        mainView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            mainView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            mainView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            mainView.topAnchor.constraint(equalTo: contentView.topAnchor),
            mainView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
            ])
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }*/
}

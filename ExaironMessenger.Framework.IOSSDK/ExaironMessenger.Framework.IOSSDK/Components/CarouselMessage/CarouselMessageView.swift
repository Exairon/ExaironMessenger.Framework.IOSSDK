//
//  CarouselMessageView.swift
//  ExaironFramework
//
//  Created by Exairon on 24.03.2023.
//

import UIKit
import ScalingCarousel

class CarouselMessageView: UIView {
    
    fileprivate var scalingCarousel: ScalingCarouselView!
    @IBOutlet weak var view: UIView!
    @IBOutlet weak var mainView: UIView!
    var cards: [Element]!

    private func addCarousel() {
            
        let frame = CGRect(x: 0, y: 0, width: 0, height: 0)
        scalingCarousel = ScalingCarouselView(withFrame: frame, andInset: 50)
        scalingCarousel.scrollDirection = .horizontal
        scalingCarousel.dataSource = self
        scalingCarousel.delegate = self
        scalingCarousel.translatesAutoresizingMaskIntoConstraints = false
        scalingCarousel.backgroundColor = .white
        scalingCarousel.register(CarouselCardView.self, forCellWithReuseIdentifier: "cell")
        view.addSubview(scalingCarousel)
        scalingCarousel.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 1).isActive = true
        var buttonCount = 0
        for card in cards {
            if card.buttons?.count ?? 0 > buttonCount {
                buttonCount = card.buttons!.count
            }
        }
        let height = (buttonCount * 30) + 330
        mainView.heightAnchor.constraint(greaterThanOrEqualToConstant: CGFloat(height)).isActive = true
        scalingCarousel.heightAnchor.constraint(lessThanOrEqualToConstant: CGFloat(height)).isActive = true
        scalingCarousel.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        scalingCarousel.topAnchor.constraint(equalTo: view.topAnchor, constant: 10).isActive = true
    }
    
    init(frame: CGRect, cards: [Element]) {
        super.init(frame: frame)
        self.cards = cards
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    func initialView() {
        addCarousel()
    }
    
    func commonInit() {
        let viewFromXib = Bundle(for: Exairon.self).loadNibNamed("CarouselMessageView", owner: self, options: nil)![0] as! UIView
        viewFromXib.frame = self.bounds
        addSubview(viewFromXib)
        initialView()
    }

}

extension CarouselMessageView: UICollectionViewDataSource {
        
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return cards.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)
        if let scalingCell = cell as? CarouselCardView {
            let item = cards[indexPath.row]
            scalingCell.initialView(card: item)
        }
        
        DispatchQueue.main.async {
            cell.setNeedsLayout()
            cell.layoutIfNeeded()
            
        }

        return cell
    }
}

extension CarouselMessageView: UICollectionViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        scalingCarousel.didScroll()
    }
}

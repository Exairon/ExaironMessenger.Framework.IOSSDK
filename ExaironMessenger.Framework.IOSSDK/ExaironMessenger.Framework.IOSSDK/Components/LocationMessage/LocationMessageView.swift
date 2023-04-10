//
//  LocationMessageView.swift
//  ExaironFramework
//
//  Created by Exairon on 24.03.2023.
//

import UIKit
import MapKit

class LocationMessageView: UIView {

    @IBOutlet weak var locationButton: UIButton!
    @IBOutlet weak var locationView: UIView!
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var textView: UILabel!
    
    var coordinate: CLLocationCoordinate2D!
    var sender: String!

    init(frame: CGRect, coordinate: CLLocationCoordinate2D, sender: String) {
        super.init(frame: frame)
        self.coordinate = coordinate
        self.sender = sender
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    
    @IBAction func locationTapped(_ sender: UIButton) {
        let mapItem = MKMapItem(placemark: MKPlacemark(coordinate: coordinate, addressDictionary:nil))
        mapItem.name = Localization.init().locale(key: "targetLocation")
        mapItem.openInMaps(launchOptions: [MKLaunchOptionsDirectionsModeKey : MKLaunchOptionsDirectionsModeDriving])
    }

    func initialView() {
        let color = WidgetSettings.shared.data?.color
        var textColor: String!
        var backColor: String!

        if sender == "bot_uttered" {
            textColor = color?.botMessageFontColor ?? "#FFFFFF"
            backColor = color?.botMessageBackColor ?? "#9500c2"
        } else {
            textColor = color?.userMessageFontColor ?? "#FFFFFF"
            backColor = color?.userMessageBackColor ?? "#9500c2"
        }
        
        locationButton.addTarget(self, action: #selector(locationTapped(_:)), for: .touchUpInside)
        locationView.backgroundColor = UIColor(hexString: backColor)
        locationButton.titleLabel?.font = .systemFont(ofSize: 40.0, weight: .bold)
        textView.text = Localization.init().locale(key: "location")
        locationView.layer.cornerRadius = 10
        locationView.layer.masksToBounds = true
        textView.font = UIFont(name: "OpenSans-Regular", size: textView.font.pointSize)
        textView.textColor = UIColor(hexString: textColor)
        let margins = self
        if sender == "bot_uttered" {
            locationView.leadingAnchor.constraint(equalTo: margins.leadingAnchor, constant: 10).isActive = true
        } else {
            locationView.trailingAnchor.constraint(equalTo: margins.trailingAnchor, constant: -10).isActive = true
        }
    }
    
    func commonInit() {
        let bundle = Bundle(for: Exairon.self)
        let viewFromXib = bundle.loadNibNamed("LocationMessageView", owner: self, options: nil)![0] as! UIView
        viewFromXib.frame = self.bounds
        addSubview(viewFromXib)
        initialView()
    }
}

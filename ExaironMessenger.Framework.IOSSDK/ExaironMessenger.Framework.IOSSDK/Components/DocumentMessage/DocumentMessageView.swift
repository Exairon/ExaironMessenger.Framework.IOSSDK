//
//  DocumentMessageView.swift
//  ExaironFramework
//
//  Created by Exairon on 24.03.2023.
//

import UIKit

class DocumentMessageView: UIView {

    @IBOutlet weak var documentButton: UIButton!
    @IBOutlet weak var documentView: UIView!
    @IBOutlet weak var mainView: UIView!
    
    var originalName = ""
    var sender = ""
    var documentUrl = ""
    
    init(frame: CGRect, originalName: String, sender: String, documentUrl: String) {
        super.init(frame: frame)
        self.originalName = originalName
        self.sender = sender
        self.documentUrl = documentUrl
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    @IBAction func openDocument(_ sender: UIButton) {
        DispatchQueue.main.async {
            if let url = URL(string: self.documentUrl) {
                UIApplication.shared.open(url)
            }
        }
    }
    
    func initialView() {
        documentButton.layer.cornerRadius = 10
        documentButton.layer.borderWidth = 1
        documentButton.layer.borderColor = UIColor(hexString: "#9500c2").cgColor
        documentButton.setTitle("📁 \(originalName)", for: .normal)
        documentButton.tintColor = UIColor(hexString: "#FFFFFF")
        documentButton.backgroundColor = UIColor(hexString: "#9500c2")
        documentView.backgroundColor = UIColor(hexString: "#9500c2")
        documentView.layer.cornerRadius = 10
        documentView.layer.masksToBounds = true
        
        documentButton.titleLabel?.font = UIFont(name: "OpenSans-Regular", size: documentButton.titleLabel?.font.pointSize ?? 16)
        
        let margins = mainView.layoutMarginsGuide
        if sender == "bot_uttered" {
            documentView.leadingAnchor.constraint(equalTo: margins.leadingAnchor, constant: 0).isActive = true
        } else {
            documentView.trailingAnchor.constraint(equalTo: margins.trailingAnchor, constant: 0).isActive = true
        }
    }
    
    func commonInit() {
        let bundle = Bundle(for: Exairon.self)
        let viewFromXib = bundle.loadNibNamed("DocumentMessageView", owner: self, options: nil)![0] as! UIView
        viewFromXib.frame = self.bounds
        addSubview(viewFromXib)
        initialView()
    }
}

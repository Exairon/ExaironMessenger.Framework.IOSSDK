//
//  MessageTimeView.swift
//  ExaironFramework
//
//  Created by Exairon on 23.03.2023.
//

import UIKit

class MessageTimeView: UIView {
    
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var timeView: UIView!

    var messageTime: Int64 = 0
    var sender: String = ""
    
    init(frame: CGRect, time: Int64, sender: String) {
        super.init(frame: frame)
        self.messageTime = time
        self.sender = sender
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    func dateFormatter(time: Int64) -> String{
        let dateFormatterPrintToday = DateFormatter()
        dateFormatterPrintToday.dateFormat = "HH:mm"
        
        let dateFormatterPrint = DateFormatter()
        dateFormatterPrint.dateFormat = "dd/M/yyyy HH:mm"
        
        let messageDate = Date(milliseconds: time)
        if Calendar.current.isDateInToday(messageDate) {
            return dateFormatterPrintToday.string(from: messageDate)
        } else {
            return dateFormatterPrint.string(from: messageDate)
        }
    }
    
    func initialView() {
        timeLabel.text = dateFormatter(time: messageTime)
        timeLabel.textColor = UIColor(hexString: "#6C6D6F")
        timeLabel.font = UIFont(name: "OpenSans-Regular", size: 12)
        timeView.layer.masksToBounds = true
        
        let margins = mainView.layoutMarginsGuide
        if sender == "bot_uttered" {
            timeLabel.leadingAnchor.constraint(equalTo: margins.leadingAnchor, constant: 10).isActive = true
        } else {
            timeLabel.trailingAnchor.constraint(equalTo: margins.trailingAnchor, constant: -10).isActive = true
        }
    }
    
    func commonInit() {
        let bundle = Bundle(for: Exairon.self)
        let viewFromXib = bundle.loadNibNamed("MessageTimeView", owner: self, options: nil)![0] as! UIView
        viewFromXib.frame = self.bounds
        addSubview(viewFromXib)
        initialView()
    }
}

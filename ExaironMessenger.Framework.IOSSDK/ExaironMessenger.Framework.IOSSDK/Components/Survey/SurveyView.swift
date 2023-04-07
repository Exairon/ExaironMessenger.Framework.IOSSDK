//
//  SurveyView.swift
//  ExaironFramework
//
//  Created by Exairon on 27.03.2023.
//

import UIKit

class SurveyView: UIView {

    @IBOutlet weak var onePointButton: UILabel!
    @IBOutlet weak var twoPointButton: UILabel!
    @IBOutlet weak var threePointButton: UILabel!
    @IBOutlet weak var fourPointButton: UILabel!
    @IBOutlet weak var fivePointButton: UILabel!
    @IBOutlet weak var surveyComment: UITextField!
    @IBOutlet weak var submitBtn: UIButton!
    @IBOutlet weak var cancelBtn: UIButton!
    
    var value: Int? = nil

    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    @IBAction func oneButtonTapped(_ sender: UILabel) {
        let buttons = [twoPointButton, threePointButton, fourPointButton, fivePointButton]
        for button in buttons {
            button?.alpha = 0.5
            
        }
        onePointButton.alpha = 1
        value = 1
    }
    @IBAction func twoButtonTapped(_ sender: UILabel) {
        let buttons = [onePointButton, threePointButton, fourPointButton, fivePointButton]
        for button in buttons {
            button?.alpha = 0.5
        }
        twoPointButton.alpha = 1
        value = 2
    }
    @IBAction func threeButtonTapped(_ sender: UILabel) {
        let buttons = [onePointButton, twoPointButton, fourPointButton, fivePointButton]
        for button in buttons {
            button?.alpha = 0.5
            
        }
        threePointButton.alpha = 1
        value = 3
    }
    @IBAction func fourButtonTapped(_ sender: UILabel) {
        let buttons = [onePointButton, twoPointButton, threePointButton, fivePointButton]
        for button in buttons {
            button?.alpha = 0.5
            
        }
        fourPointButton.alpha = 1
        value = 4
    }
    @IBAction func fiveButtonTapped(_ sender: UILabel) {
        let buttons = [onePointButton, twoPointButton, threePointButton, fourPointButton]
        for button in buttons {
            button?.alpha = 0.5
            
        }
        fivePointButton.alpha = 1
        value = 5
    }

    @IBAction func submit(_ sender: UISlider) {
        if value != nil {
            sendSurvey(value: value!, comment: surveyComment.text ?? "")
        }
    }
    
    @IBAction func cancel(_ sender: UISlider) {
        writeMessage(messages: [])
        State.shared.oldMessages = []
        State.shared.messageArray = []
        writeStringStorage(value: "", key: "conversationId")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            closeFramework()
        }
    }
    
    func initialView() {
        let buttons = [onePointButton, twoPointButton, threePointButton, fourPointButton, fivePointButton]

        for button in buttons {
            button?.alpha = 0.5
        }
        
        let tapSender1 = UITapGestureRecognizer(target: self, action: #selector(oneButtonTapped))
        onePointButton?.isUserInteractionEnabled = true
        onePointButton?.addGestureRecognizer(tapSender1)
        
        let tapSender2 = UITapGestureRecognizer(target: self, action: #selector(twoButtonTapped))
        twoPointButton?.isUserInteractionEnabled = true
        twoPointButton?.addGestureRecognizer(tapSender2)
        
        let tapSender3 = UITapGestureRecognizer(target: self, action: #selector(threeButtonTapped))
        threePointButton?.isUserInteractionEnabled = true
        threePointButton?.addGestureRecognizer(tapSender3)
        
        let tapSender4 = UITapGestureRecognizer(target: self, action: #selector(fourButtonTapped))
        fourPointButton?.isUserInteractionEnabled = true
        fourPointButton?.addGestureRecognizer(tapSender4)
        
        let tapSender5 = UITapGestureRecognizer(target: self, action: #selector(fiveButtonTapped))
        fivePointButton?.isUserInteractionEnabled = true
        fivePointButton?.addGestureRecognizer(tapSender5)
        
        
        cancelBtn.tintColor = UIColor(hexString: "#9500c2")
        cancelBtn.layer.cornerRadius = 10
        cancelBtn.layer.borderWidth = 1
        cancelBtn.layer.borderColor = UIColor(hexString: "#9500c2").cgColor
        cancelBtn.addTarget(self, action: #selector(cancel(_:)), for: .touchUpInside)

        submitBtn.tintColor = UIColor(hexString: "#FFFFFF")
        submitBtn.backgroundColor = UIColor(hexString: "#9500c2")
        submitBtn.layer.cornerRadius = 10
        submitBtn.layer.borderWidth = 1
        submitBtn.layer.borderColor = UIColor(hexString: "#9500c2").cgColor
        submitBtn.addTarget(self, action: #selector(submit(_:)), for: .touchUpInside)

        
    }
    
    func commonInit() {
        let viewFromXib = Bundle(for: Exairon.self).loadNibNamed("SurveyView", owner: self, options: nil)![0] as! UIView
        viewFromXib.frame = self.bounds
        addSubview(viewFromXib)
        initialView()
    }

}

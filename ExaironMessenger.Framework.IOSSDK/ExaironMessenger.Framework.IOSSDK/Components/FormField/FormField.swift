//
//  FormField.swift
//  ExaironMessenger.Framework.IOSSDK
//
//  Created by Exairon on 10.04.2023.
//

import UIKit

class FormFieldView: UIView {
    
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var labelView: UILabel!
    @IBOutlet weak var textField: UITextField!
    
    var label: String?
    var placeholder: String?
    var value: String?
    var require: Bool?

    init(frame: CGRect, label: String, placeholder: String, value: String?, require: Bool) {
        super.init(frame: frame)
        self.label = label
        self.placeholder = placeholder
        self.require = require
        self.value = value
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    func initialView() {
        labelView.text = "\(Localization.init().locale(key: label ?? "")) \(require ?? false ? "*" : "")"
        textField.placeholder = Localization.init().locale(key: placeholder ?? "")
        textField.backgroundColor = UIColor(hexString: "#1E1E1E10")
        textField.layer.cornerRadius = 10
        //textField.isUserInteractionEnabled = true
        
        if value != nil && value != "" {
            textField.text = value
        }
        
    }
    
    func commonInit() {
        let bundle = Bundle(for: Exairon.self)
        let viewFromXib = bundle.loadNibNamed("FormFieldView", owner: self, options: nil)![0] as! UIView
        viewFromXib.frame = self.bounds
        addSubview(viewFromXib)
        initialView()
    }

}

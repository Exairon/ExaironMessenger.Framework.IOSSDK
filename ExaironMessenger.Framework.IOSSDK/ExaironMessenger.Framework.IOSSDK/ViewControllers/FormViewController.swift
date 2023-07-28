//
//  FormViewController.swift
//  ExaironMessenger.Framework.IOSSDK
//
//  Created by Exairon on 7.04.2023.
//

import UIKit
import libPhoneNumber_iOS

class FormViewController: UIViewController {
    
    @IBOutlet weak var bgView: UIView!
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var formStackView: UIStackView!
    @IBOutlet weak var formStackMainView: UIView!
    @IBOutlet weak var headerDescriptionLabel: UILabel!
    @IBOutlet weak var footerDescriptionLabel: UILabel!
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var submitButton: UIButton!
    var statusBarBackgroundColor: UIColor?
    var headerHeight: Double = 0
    var nameFieldView: FormFieldView?
    var surnameFieldView: FormFieldView?
    var emailFieldView: FormFieldView?
    var phoneFieldView: PhoneFormFieldView?
    var countryCodes = [[String]]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        State.shared.isFormOpen = true
        State.shared.navigationController = self.navigationController
        State.shared.storyboard = self.storyboard
        
        self.countryCodes = getAllCountryCodes()
        
        let color = WidgetSettings.shared.data?.color
        let header = HeaderView(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        let headerMargins = headerView.layoutMarginsGuide
        header.headerView.translatesAutoresizingMaskIntoConstraints = false
        headerView.addSubview(header.headerView)
        headerView.backgroundColor = UIColor(hexString: color?.headerColor ?? "#FFFFFF")
        setConstraint(view: header.headerView, margins: headerMargins)
        bgView.backgroundColor = UIColor(hexString: color?.headerColor ?? "#FFFFFF")
        
        header.closeButton.widthAnchor.constraint(equalToConstant: 0).isActive = true
        header.closeButton.heightAnchor.constraint(equalToConstant: 0).isActive = true
        
        let tapBack = UITapGestureRecognizer(target: self, action: #selector(backButtonPressed))
        header.backButton.isUserInteractionEnabled = true
        header.backButton.addGestureRecognizer(tapBack)
        
        headerDescriptionLabel.text = Localization.init().locale(key: "formTitle")
        footerDescriptionLabel.text = Localization.init().locale(key: "formDesc")
        errorLabel.text = ""
        submitButton.setTitle(" \(Localization.init().locale(key: "startSession")) ", for: .normal)
        submitButton.backgroundColor = UIColor(hexString: color?.headerColor ?? "#1e1e1e")
        submitButton.setTitleColor(UIColor(hexString: color?.headerFontColor ?? "#ffffff"), for: .normal)
        submitButton.layer.cornerRadius = 10
        
        if getFormFields().showNameField {
            nameFieldView = FormFieldView(frame: CGRect(x: 0, y: 0, width: 0, height: 0), label: "name", placeholder: "namePlaceholder", value: Exairon.shared.name, require: getFormFields().nameFieldRequired)
            addFormFieldView(fieldView: nameFieldView!)
        }
        if getFormFields().showSurnameField {
            surnameFieldView = FormFieldView(frame: CGRect(x: 0, y: 0, width: 0, height: 0), label: "surname", placeholder: "surnamePlaceholder", value: Exairon.shared.surname, require: getFormFields().surnameFieldRequired)
            addFormFieldView(fieldView: surnameFieldView!)
        }
        if getFormFields().showEmailField {
            emailFieldView = FormFieldView(frame: CGRect(x: 0, y: 0, width: 0, height: 0), label: "email", placeholder: "emailPlaceholder", value: Exairon.shared.email, require: getFormFields().emailFieldRequired)
            addFormFieldView(fieldView: emailFieldView!)
        }
        if getFormFields().showPhoneField {
            phoneFieldView = PhoneFormFieldView(frame: CGRect(x: 0, y: 0, width: 0, height: 0), label: "phone", placeholder: "phonePlaceholder", value: Exairon.shared.phone, require: getFormFields().phoneFieldRequired)
            addFormFieldView(fieldView: phoneFieldView!)
        }
        formStackMainView.heightAnchor.constraint(equalToConstant: headerHeight).isActive = true
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
               view.addGestureRecognizer(tapGesture)
        // Do any additional setup after loading the view.
    }
    
    func getAllCountryCodes() -> [[String]] {
        var countrys = [[String]]()
        let countryList = GlobalConstants.Constants.codePrefixes
        for item in countryList {
            countrys.append(item.value)
        }
        let sorted = countrys.sorted(by: {$0[0] < $1[0]})
        return sorted
    }
    
    // MARK: - Create UIPickerView
    
    func picker(){
        let picker = UIPickerView()
        picker.delegate = self
        picker.dataSource = self
        phoneFieldView?.counrtyCodeField.inputView = picker
        picker.selectRow(0, inComponent: 0, animated: true)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    @IBAction func submitForm(_ sender: Any) {
        let nameCondition = getFormFields().nameFieldRequired ? isValidNameOrSurname(text: nameFieldView?.textField?.text ?? "") : (!getFormFields().showNameField || ((nameFieldView?.textField?.text?.count ?? 0 > 0) ? isValidNameOrSurname(text: nameFieldView?.textField?.text ?? "") : true))
        
        let surnameCondition = getFormFields().surnameFieldRequired ? isValidNameOrSurname(text: surnameFieldView?.textField?.text ?? "") : (!getFormFields().showSurnameField || ((surnameFieldView?.textField?.text?.count ?? 0 > 0) ? isValidNameOrSurname(text: surnameFieldView?.textField?.text ?? "") : true))
        
        let emailCondition = getFormFields().emailFieldRequired ? isValidEmail(email: emailFieldView?.textField?.text ?? "") : (!getFormFields().showEmailField || ((emailFieldView?.textField?.text?.count ?? 0 > 0) ? isValidEmail(email: emailFieldView?.textField?.text ?? "") : true))
        
        let phoneFieldText = "\(phoneFieldView?.counrtyCodeField.text ?? "") \(phoneFieldView?.textField.text ?? "")"
        let phoneCondition = getFormFields().phoneFieldRequired ? isValidPhoneNumber(phone: phoneFieldText ) : (!getFormFields().showPhoneField || ((phoneFieldView?.textField?.text?.count ?? 0 > 0) ? isValidPhoneNumber(phone: phoneFieldText) : true))
        
        if (nameCondition && surnameCondition && emailCondition && phoneCondition) {
            self.sessionRequest() { socketResponse in
                DispatchQueue.main.async {
                    let userToken: String = readStringStorage(key: "userToken") ?? UUID().uuidString
                    writeStringStorage(value: userToken, key: "userToken")
                    User.shared.name = self.nameFieldView?.textField?.text
                    User.shared.surname = self.surnameFieldView?.textField?.text
                    User.shared.email = self.emailFieldView?.textField?.text
                    User.shared.phone = "\(self.phoneFieldView?.counrtyCodeField.text ?? "")\(self.phoneFieldView?.textField.text ?? "")"
                    User.shared.user_unique_id = Exairon.shared.user_unique_id
                    writeUserInfo()
                    State.shared.oldMessages = []
                    State.shared.messageArray = []
                    writeMessage(messages: State.shared.messageArray)
                    let viewController = self.storyboard?.instantiateViewController(withIdentifier: "chatViewController") as! ChatViewController
                    self.navigationController?.pushViewController(viewController, animated: true)
                    State.shared.isChatOpen = true
                }
            }
        } else {
            errorLabel.text = Localization.init().locale(key: "formError")
        }
        
    }
    
    func isValidNameOrSurname(text: String) -> Bool {
        return text.count >= 2
    }
    
    func isValidEmail(email: String) -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        let emailPredicate = NSPredicate(format:"SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluate(with: email)
    }
    
    func isValidPhoneNumber(phone: String) -> Bool {
        guard let phoneUtil = NBPhoneNumberUtil.sharedInstance() else {
            return false
        }
        do {
            let parsedPhoneNumber = try phoneUtil.parse(phone, defaultRegion: nil)
            return phoneUtil.isValidNumber(parsedPhoneNumber)
        } catch {
            return false
        }
    }
    
    func sessionRequest(completion: @escaping (_ success: String) -> Void) {
        let conversationId = readStringStorage(key: "conversationId")
        let sessionRequestObj = SessionRequest(session_id: conversationId, channelId: Exairon.shared.channelId)
        SocketService.shared.socketEmit(eventName: "session_request", object: sessionRequestObj)
        let socket = SocketService.shared.getSocket()
        socket?.once("session_confirm") {data, ack in
            guard let socketResponse = data[0] as? String else {
                return
            }
            if socketResponse != conversationId {
                writeMessage(messages: [])
            }
            writeStringStorage(value: socketResponse, key: "conversationId")
            completion(socketResponse)
        }
    }
    
    func addFormFieldView(fieldView: AnyObject) {
        formStackView.addArrangedSubview(fieldView.mainView)

        let margins = formStackMainView.layoutMarginsGuide
        fieldView.mainView.leadingAnchor.constraint(equalTo: margins.leadingAnchor).isActive = true
        fieldView.mainView.trailingAnchor.constraint(equalTo: margins.trailingAnchor).isActive = true
        fieldView.mainView.topAnchor.constraint(equalTo: margins.topAnchor, constant: headerHeight).isActive = true
        fieldView.textField.delegate = self
        
        if (fieldView.counrtyCodeField != nil) {
            // picker view function calling
             picker()
            
        }

        headerHeight += 100
    }
    
    func getFormFields() -> FormFields {
        return WidgetSettings.shared.data?.formFields ?? FormFields(emailFieldRequired: false, nameFieldRequired: false, phoneFieldRequired: false, showEmailField: false, showNameField: true, showPhoneField: false, showSurnameField: false, surnameFieldRequired: false)
    }
    
    @objc func backButtonPressed () {
        if self.navigationController != nil {
            if let navigationController = self.navigationController {
                let viewControllers = navigationController.viewControllers
                let targetIndex = viewControllers.count - 3 // n-2 index
                if targetIndex >= 0 && targetIndex < viewControllers.count {
                    let targetViewController = viewControllers[targetIndex]
                    navigationController.popToViewController(targetViewController, animated: true)
                }
            }
        }
    }
    
    func setConstraint(view: UIView, margins: UILayoutGuide) {
        view.leadingAnchor.constraint(equalTo: margins.leadingAnchor).isActive = true
        view.trailingAnchor.constraint(equalTo: margins.trailingAnchor).isActive = true
        view.bottomAnchor.constraint(equalTo: margins.bottomAnchor).isActive = true
        view.topAnchor.constraint(equalTo: margins.topAnchor).isActive = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        do {
            if #available(iOS 13.0, *) {
                let statusBar = UIView(frame: (UIApplication.shared.keyWindow?.windowScene?.statusBarManager?.statusBarFrame)!)
                statusBarBackgroundColor = statusBar.backgroundColor
                statusBar.backgroundColor = UIColor(hexString: WidgetSettings.shared.data?.color.headerColor ?? "#FF0000")
                UIApplication.shared.keyWindow?.addSubview(statusBar)
            } else {
                guard let statusBar = UIApplication.shared.value(forKeyPath: "statusBar") as? UIView else { return }
                statusBarBackgroundColor = statusBar.backgroundColor
                statusBar.backgroundColor = UIColor(hexString: WidgetSettings.shared.data?.color.headerColor ?? "#FF0000")
            }
        }
        
        /*
        if let statusBar = UIApplication.shared.value(forKey: "statusBar") as? UIView {
            statusBar.backgroundColor = UIColor(hexString: WidgetSettings.shared.data?.color.headerColor ?? "#FF0000")
        }*/
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        State.shared.isChatOpen = false
        do {
            if #available(iOS 13.0, *) {
                let statusBar = UIView(frame: (UIApplication.shared.keyWindow?.windowScene?.statusBarManager?.statusBarFrame)!)
                statusBar.backgroundColor = nil
                UIApplication.shared.keyWindow?.addSubview(statusBar)
            } else {
                guard let statusBar = UIApplication.shared.value(forKeyPath: "statusBar") as? UIView else { return }
                statusBar.backgroundColor = statusBarBackgroundColor
            }
        }
        
        /*
        if let statusBar = UIApplication.shared.value(forKey: "statusBar") as? UIView {
            statusBar.backgroundColor = nil
        }*/
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
}

extension FormViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

extension FormViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    
    // MARK: - UIPickerView Delegate Methods
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return countryCodes.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        let code = countryCodes[row]
        return "\(code[0]) +\(code[1])"
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let code = countryCodes[row]
        phoneFieldView?.counrtyCodeField.text = "+\(code[1])"
    }
}

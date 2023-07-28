//
//  ExaironViewController.swift
//  ExaironMessenger.Framework.IOSSDK
//
//  Created by Exairon on 7.04.2023.
//

import UIKit

public class ExaironViewController: UIViewController, UIGestureRecognizerDelegate {
    
    @IBOutlet weak var splashIconView: UIImageView!
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.interactivePopGestureRecognizer?.delegate = self
        splashIconView.image = UIImage(named:"exa_splash.png")
        
        ApiService.shared.getWidgetSettingsApiCall(){ widgetSettings in
            switch(widgetSettings) {
            case .failure(let error):
                print(error)
            case .success(let data):
                State.shared.avatarUrl = Exairon.shared.src + "/uploads/channels/" + (data.data?.avatar ?? "")
                for _message in data.data?.messages ?? [] {
                    if(_message.lang == Exairon.shared.language) {
                        State.shared.widgetMessage = _message
                    }
                }
                if (State.shared.widgetMessage == nil) {
                    State.shared.widgetMessage = data.data?.messages[0]
                }
                WidgetSettings.shared.status = data.status
                WidgetSettings.shared.data = data.data
                WidgetSettings.shared.geo = data.geo
                WidgetSettings.shared.triggerRules = data.triggerRules
                
                let userToken: String = readStringStorage(key: "userToken") ?? UUID().uuidString
                writeStringStorage(value: userToken, key: "userToken")
                ApiService.shared.getCustomerSessions(userToken: userToken, user_unique_id: Exairon.shared.user_unique_id ?? "") { customerSessions in
                    switch(customerSessions) {
                    case .failure(let error):
                        print(error)
                    case .success(let data):
                        State.shared.customerSessions = data.data
                        DispatchQueue.main.async {
                            let viewController = self.storyboard?.instantiateViewController(withIdentifier: "sessionListViewController") as! SessionListViewController
                            self.navigationController?.pushViewController(viewController, animated: true)
                        }
                        
                    }
                }
                
            }
        }
    }
    
    
    @objc func dismissFrameworkNavigationController() {
        self.navigationController?.dismiss(animated: true, completion: nil)
    }
    
    public func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return false
    }
}

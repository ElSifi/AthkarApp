//
//  ContactDeveloperViewController.swift
//  DailyAthkar
//
//  Created by Mohamed ElSIfi on 9/1/18.
//  Copyright © 2018 Badi3.com. All rights reserved.
//

import UIKit

class ContactDeveloperViewController: UIViewController {
    @IBOutlet weak var topLabel: UILabel!{
        didSet{
            topLabel.text = "contact developer top text".localized
        }
    }
    @IBOutlet weak var emailTextField: UITextField!{
        didSet{
            emailTextField.borderStyle = .none
            emailTextField.layer.cornerRadius = 6
            emailTextField.layer.borderColor = DA_STYLE.darkThemeColor.cgColor
            emailTextField.layer.borderWidth = 1
            emailTextField.placeholder = "optional email address".localized
        }
    }
    @IBOutlet weak var textView: UITextView!{
        didSet{
            textView.layer.cornerRadius = 6
            textView.layer.borderColor = DA_STYLE.darkThemeColor.cgColor
            textView.layer.borderWidth = 1
        }
    }
    @IBOutlet weak var sendButton: UIButton!{
        didSet{
            sendButton.backgroundColor = DA_STYLE.darkThemeColor
            sendButton.setTitleColor(UIColor.white, for: .normal)
            sendButton.setTitle("send".localized, for: .normal)
            sendButton.layer.cornerRadius = 6
        }
    }
    
    var autoDismiss = false;
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if(!autoDismiss){
            self.sendMessage(intended: false)
        }
    }
    @IBAction func sendAction(_ sender: Any) {
        self.sendMessage(intended: true)
    }
    
    func sendMessage(intended : Bool){
//        self.textView.resignFirstResponder()
//        let text = self.textView.text ?? ""
//        if(text.count < 2){
//            self.showToast(message: "short message error".localized, completion: nil)
//            return
//        }
//        let params : [String : String] = [
//            "from":"DA User <da@mg.Badi3.com>",
//            "to":"m@elsifi.com",
//            "subject":"From the Athkar App",
//            "text":"\(self.emailTextField.text ?? "no email") - \(text) - Intended \(intended)"
//        ]
//        let headers : [String : String] = ["Authorization" : "Basic YXBpOjk3MjAxYzU1YzRmMWZjZTQxMzI0NDU5ODlkM2JlZWY3LWMxZmUxMzFlLWFlODg1ZGNm"]
//        var indicator : MBProgressHUD?
//        if(intended){
//             indicator = MBProgressHUD.showAdded(to: self.view, animated: true)
//        }
//        
//        Alamofire.request("https://api.mailgun.net/v3/mg.Badi3.com/messages", method: .post, parameters: params, headers: headers).responseJSON { (response) in
//            indicator?.hide(animated: true)
//            switch(response.result){
//            case .success(let value):
//                let json = JSON.init(value)
//                print("message response \(json)")
//                if let code = response.response?.statusCode, code == 200{
//                    print("code \(code)")
//                    self.showToast(message: "message sent".localized, long: true, completion: {
//                        self.autoDismiss = true
//                        _  = self.navigationController?.popViewController(animated: true)
//                    })
//                }else{
//                    self.showToast(message: "could not send your message".localized, long: true, completion: nil)
//                }
//                
//            case .failure(let error):
//                print("message error \(error.localizedDescription)")
//                self.showToast(message: error.localizedDescription, completion: nil)
//            }
//        }
 
        
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "contact developer".localized
        let tapGesture = UITapGestureRecognizer.init(target: self, action: #selector(ContactDeveloperViewController.viewTapped(_:)))
        self.view.addGestureRecognizer(tapGesture)
    }
    
    @objc func viewTapped( _ sender : UITapGestureRecognizer){
        print("viewTapped")
        self.textView.resignFirstResponder()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.textView.becomeFirstResponder()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

}

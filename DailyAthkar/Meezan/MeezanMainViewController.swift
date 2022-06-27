//
//  MeezanMainViewController.swift
//  DailyAthkar
//
//  Created by badi3 on 4/5/19.
//  Copyright © 2019 Badi3.com. All rights reserved.
//
import FirebaseAuth
import UIKit
import FirebaseFirestore

class MeezanMainViewController: UIViewController {

    @IBOutlet weak var navBarBGView: UIView!{
        didSet{
            let viewVisualEffectView   = UIVisualEffectView(effect: UIBlurEffect(style: .dark))
            navBarBGView.insertSubview(viewVisualEffectView, at: 0)
            
            viewVisualEffectView.translatesAutoresizingMaskIntoConstraints = false
            viewVisualEffectView.leadingAnchor.constraint(equalTo: navBarBGView.leadingAnchor).isActive = true
            viewVisualEffectView.trailingAnchor.constraint(equalTo: navBarBGView.trailingAnchor).isActive = true
            viewVisualEffectView.topAnchor.constraint(equalTo: navBarBGView.topAnchor).isActive = true
            viewVisualEffectView.bottomAnchor.constraint(equalTo: navBarBGView.bottomAnchor).isActive = true
        }
    }
    
    
    @IBOutlet weak var meezanCount: UILabel!
    
    @IBAction func shareAction(_ sender: UIButton) {
        let hud = MBProgressHUD.showAdded(to: self.view, animated: true)
        Meezan.getMyInvitationLink { [weak self] (link, error) in
            hud.hide(animated: true)
            if let error = error as NSError?{
                switch(error.code){
                case 401:
                    guard let self = self else { return }
                    UIAlertController.showAlert(in: self, withTitle: "sign in is required to keep track of your invites".localized, message: nil, cancelButtonTitle: nil, destructiveButtonTitle: nil, otherButtonTitles: ["yes, Sign me up".localized, "no, share without keeping track".localized], tap: { (controller, action, index) in
                        print(index)
                        
                        if(index == 2){
                            Meezan.loginWithPhone(viewController: self)
                        }else if(index == 3){
                            let hud = MBProgressHUD.showAdded(to: self.view, animated: true)
                            Meezan.getMyInvitationLink(withoutLogin: true, completion: { (link, error) in
                                hud.hide(animated: true)
                                if let theURL = link{
                                    let textToShare = String(format: NSLocalizedString("share message", comment: ""), theURL)
                                    let objectsToShare:URL = URL(string: theURL)!
                                    let sharedObjects:[AnyObject] = [objectsToShare as AnyObject , textToShare as AnyObject]
                                    let activityViewController = UIActivityViewController(activityItems : sharedObjects, applicationActivities: nil)
                                    activityViewController.popoverPresentationController?.sourceView = self.view
                                    self.present(activityViewController, animated: true, completion: nil)
                                }
                            })
                        }
                    })
                    
                    
                default:
                    break
                }
                return
            }
            
            if let theURL = link{
                let textToShare = String(format: NSLocalizedString("share message", comment: ""), theURL)
                let objectsToShare:URL = URL(string: theURL)!
                let sharedObjects:[AnyObject] = [objectsToShare as AnyObject , textToShare as AnyObject]
                let activityViewController = UIActivityViewController(activityItems : sharedObjects, applicationActivities: nil)
                activityViewController.popoverPresentationController?.sourceView = self?.view
                self?.present(activityViewController, animated: true, completion: nil)
            }
            
        }
    }
    
    var countListenr : ListenerRegistration?
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        
        if let currentUser = Auth.auth().currentUser{
            let hud = MBProgressHUD.showAdded(to: self.view, animated: true)
            print("currentUser.uid \(currentUser.uid)")
            let db = Firestore.firestore().collection("users")
            let myReference = db.document(currentUser.uid)
            
            countListenr = myReference.addSnapshotListener { [weak self] (snapshot, error) in
                hud.hide(animated: true)
                if let snapshot = snapshot, let data = snapshot.data(){
                    let count = (data["inviteesLaunchCount"] as? Int) ?? 0
                    self?.meezanCount.text = "\(count)"
                }else{
                    
                    self?.meezanCount.text = "\(0)"
                }
            }
        }else{
            print("not signed in")
            self.meezanCount.text = "-"
        }
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        countListenr?.remove()
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        
       
        
        
        let viewVisualEffectView   = UIVisualEffectView(effect: UIBlurEffect(style: .regular))
        view.insertSubview(viewVisualEffectView, at: 0)
        
        viewVisualEffectView.translatesAutoresizingMaskIntoConstraints = false
        viewVisualEffectView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
        viewVisualEffectView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
        viewVisualEffectView.topAnchor.constraint(equalTo: self.view.topAnchor).isActive = true
        viewVisualEffectView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
        
        self.title = "Meezan".localized
        
        
        let dismissButton = UIBarButtonItem.init(title: "back".localized, style: .plain, target: self, action: #selector(MeezanMainViewController.dismissAction))
        self.navigationItem.rightBarButtonItem = dismissButton

    }
    
    @objc func dismissAction(){
        self.dismiss(animated: true, completion: nil)
    }

}

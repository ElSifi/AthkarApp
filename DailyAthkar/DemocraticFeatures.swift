//
//  DemocraticFeatures.swift
//  Democracy
//
//  Created by badi3 on 4/1/21.
//  Copyright © 2021 Badi3. All rights reserved.
//

import UIKit
import Firebase


class DemocraticFeatures {
    static func listVC() -> UINavigationController{
        let listVC = DemocraticFeaturesListViewController()
        let navigationVC = UINavigationController.init(rootViewController: listVC)
        navigationVC.navigationBar.isTranslucent = false
        return navigationVC
    }
}

fileprivate struct DFFeature: Codable{
    var details, title, owner: String?
    var votes: [String]?
    var id: String?
    var shown: Bool?
    var status: String?
    
    
    var toDictionnary: [String : Any]? {
        guard let data =  try? JSONEncoder().encode(self) else {
            return nil
        }
        return try! JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: Any]
    }
    
}

extension Dictionary {
    var JSON: Data {
        do {
            return try JSONSerialization.data(withJSONObject: self, options: .prettyPrinted)
        } catch {
            return Data()
        }
    }
}

extension DataSnapshot {
    var valueToJSON: Data {
        guard var dictionary = value as? [String: Any] else {
            return Data()
        }
        dictionary["id"] = self.key
        return dictionary.JSON
    }
    
    var listToJSON: Data {
        guard let object = children.allObjects as? [DataSnapshot] else {
            return Data()
        }
        
        let dictionary: [NSDictionary] = object.compactMap { $0.value as? NSDictionary }
        
        do {
            return try JSONSerialization.data(withJSONObject: dictionary, options: .prettyPrinted)
        } catch {
            return Data()
        }
    }
}

fileprivate class DemocraticFeaturesListViewController: UIViewController, DemocraticFeaturesNewFeatureDelegate, UITableViewDataSource, UITableViewDelegate {
    
    
    
    let tableView = UITableView()
    var ref: DatabaseReference = Database.database().reference()
    var featuresList = [DFFeature]()
    
    var containerTitle: String {
        var bundleIdentifier : String = Bundle.main.bundleIdentifier ?? "app"
        bundleIdentifier = bundleIdentifier.replacingOccurrences(of: ".", with: "_")
        let containerTitle : String = "\(bundleIdentifier)_democracy"
        
        
        return containerTitle
    }
    
    var userUniqueID : String {
        return  UIDevice.current.identifierForVendor!.uuidString
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var item = self.featuresList[indexPath.row]
        let ID = item.id!
        
        let featuresRef = ref.child(containerTitle)
        
        
        let featureRef = featuresRef.child(ID)
        
        
        item.votes = (item.votes ?? [])
        
        if(item.votes!.contains(userUniqueID)){
            print("already voted")
            item.votes?.removeAll(where: { (aVote) -> Bool in
                aVote == userUniqueID
            })
        }else{
            item.votes?.append(userUniqueID)
            
        }
        
        
        
        
        item.votes = Array(Set(item.votes ?? []))
        let newValue : [String : [String]?] = ["votes": item.votes]
        
        
        featureRef.updateChildValues(newValue as [AnyHashable : Any])
        
        tableView.deselectRow(at: indexPath, animated: true)
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(CustomTableViewCell.self, forCellReuseIdentifier: "cell")
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 50
        tableView.tableFooterView = UIView()
        self.title = "Feature Requests".localized
        
        let featuresRef = ref.child(containerTitle)
        
                
        featuresRef.observe(.value) { (snapshot) in
            if snapshot.childrenCount > 0 {
                self.featuresList.removeAll()
                for aFeature in snapshot.children.allObjects as! [DataSnapshot] {
                    if let JSONString = String(data: aFeature.valueToJSON, encoding: String.Encoding.utf8) {
                        print(JSONString)
                    }
                    let feature = try? JSONDecoder().decode(DFFeature.self, from: aFeature.valueToJSON)
                    if let feature = feature{
                        self.featuresList.append(feature)
                    }
                }
                self.featuresList.sort { (aFeature, anotherFeature) -> Bool in
                    return (aFeature.votes ?? []).count > (anotherFeature.votes ?? []).count
                }
                
                self.featuresList.removeAll { (aFeature) -> Bool in
                    if((aFeature.owner ?? "") == self.userUniqueID){
                        return false
                    }
                    return !(aFeature.shown ?? false)
                }
                self.tableView.reloadData()
            }else{
                self.featuresList.removeAll()
                self.tableView.reloadData()
            }
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.featuresList.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let theFeature = self.featuresList[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! CustomTableViewCell
        cell.titleLabel.text = theFeature.title ?? "" + " "
        cell.detailsLabel.text = theFeature.details ?? "" + " "
        cell.votesCount.text = "\((theFeature.votes ?? []).count) \("votes".localized)"
        return cell

    }
    
    
    override func loadView() {
        super.loadView()
        setupTableView()
        let addAFeatureButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(DemocraticFeaturesListViewController.addAFeature))
        self.navigationItem.rightBarButtonItem = addAFeatureButton
        
    }
    func setupTableView() {
        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        tableView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        tableView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
    }
    
    @objc func addAFeature(){
        
        let addAFeatureVC = DemocraticFeaturesNewFeatureViewController()
        addAFeatureVC.delegate = self
        let navigationVC = UINavigationController.init(rootViewController: addAFeatureVC)
        
        self.present(navigationVC, animated: true, completion: nil)
    }
    
    func sendANewFeature(feature: DFFeature) {
        var feature = feature
        
        feature.votes = [self.userUniqueID]
        feature.owner = self.userUniqueID
        feature.shown = false

        if let aDictionary = feature.toDictionnary{
            self.ref.child(containerTitle).childByAutoId().setValue(aDictionary)
            
        }
        
        
    }
    
}


class CustomTableViewCell: UITableViewCell {
    
    let titleLabel = UILabel()
    let detailsLabel = UILabel()
    let votesCount = UILabel()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        titleLabel.numberOfLines = 0
        // Set any attributes of your UI components here.
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
//        titleLabel.backgroundColor = UIColor.red.withAlphaComponent(0.5)
        titleLabel.font = UIFont.preferredFont(forTextStyle: .headline)
        
        detailsLabel.numberOfLines = 0
        detailsLabel.translatesAutoresizingMaskIntoConstraints = false
//        detailsLabel.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        detailsLabel.font = UIFont.preferredFont(forTextStyle: .footnote)

        votesCount.translatesAutoresizingMaskIntoConstraints = false
//        votesCount.backgroundColor = UIColor.yellow.withAlphaComponent(0.5)
        votesCount.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        votesCount.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
        votesCount.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        votesCount.lineBreakMode = .byClipping
        //        courseName.font = UIFont.systemFont(ofSize: 20)
        
        // Add the UI components
        contentView.addSubview(titleLabel)
        contentView.addSubview(detailsLabel)
        contentView.addSubview(votesCount)
        
        
        
        
        
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 5),
            titleLabel.trailingAnchor.constraint(equalTo: votesCount.leadingAnchor, constant: 0),
            
            detailsLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 10),
            detailsLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor, constant: 0),
            detailsLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -5),
            detailsLabel.trailingAnchor.constraint(equalTo: votesCount.leadingAnchor, constant: 0),

        
            votesCount.centerYAnchor.constraint(equalTo: contentView.centerYAnchor, constant: 0),
            votesCount.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
            votesCount.widthAnchor.constraint(greaterThanOrEqualToConstant: 60)

            
            
            
            //            courseName.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20),
            //            courseName.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            //            courseName.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

fileprivate protocol DemocraticFeaturesNewFeatureDelegate: class {
    
    func sendANewFeature(feature: DFFeature)
    
}


fileprivate class DemocraticFeaturesNewFeatureViewController: UIViewController {
    var featureTitle: UITextField!
    var featureDetails: UITextView!
    weak var delegate: DemocraticFeaturesNewFeatureDelegate?
    
    
    
    override func loadView() {
        super.loadView()
        self.edgesForExtendedLayout = []
        
        setupUI()
        let backButton = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(DemocraticFeaturesNewFeatureViewController.backAction))
        self.navigationItem.leftBarButtonItem = backButton
        
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(DemocraticFeaturesNewFeatureViewController.doneAction))
        self.navigationItem.rightBarButtonItem = doneButton
        
    }
    func setupUI() {
        view.backgroundColor = UIColor.white
        
        let featureTitleLabel = UILabel.init()
        featureTitleLabel.text = "Title".localized
               featureTitleLabel.font = UIFont.preferredFont(forTextStyle: .subheadline)
        
        featureTitle = UITextField()
        featureTitle.font = UIFont.systemFont(ofSize: 15)
        featureTitle.borderStyle = UITextField.BorderStyle.roundedRect
        featureTitle.autocorrectionType = UITextAutocorrectionType.no
        featureTitle.keyboardType = UIKeyboardType.default
        featureTitle.returnKeyType = UIReturnKeyType.done
        featureTitle.clearButtonMode = UITextField.ViewMode.whileEditing;
        featureTitle.contentVerticalAlignment = UIControl.ContentVerticalAlignment.center
        featureTitle.layer.borderColor = UIColor.lightGray.cgColor

        featureTitle.heightAnchor.constraint(equalToConstant: 44.0).isActive = true
        
        
        let featureDetailsLabel = UILabel.init()
        featureDetailsLabel.text = "Details".localized
        featureDetailsLabel.font = UIFont.preferredFont(forTextStyle: .subheadline)
        
        featureDetails = UITextView()
        featureDetails.translatesAutoresizingMaskIntoConstraints = true
        featureDetails.sizeToFit()
        featureDetails.isScrollEnabled = false
        //        featureDetails.delegate = self
        featureDetails.isEditable = true
        featureDetails.layer.borderColor = UIColor.init(white: 0.8, alpha: 1).cgColor
        featureDetails.layer.borderWidth = 1.5
        featureDetails.layer.cornerRadius = 5
        
        featureDetails.heightAnchor.constraint(equalToConstant: 88).isActive = true
        
        
        //Stack View
        let stackView   = UIStackView()
        stackView.axis  = NSLayoutConstraint.Axis.vertical
        stackView.distribution  = UIStackView.Distribution.equalSpacing
        stackView.alignment = UIStackView.Alignment.fill
        stackView.spacing   = 8.0
        
        
        stackView.addArrangedSubview(featureTitleLabel)
        stackView.addArrangedSubview(featureTitle)
        stackView.addArrangedSubview(featureDetailsLabel)
        stackView.addArrangedSubview(featureDetails)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        self.view.addSubview(stackView)
        
        //Constraints
        stackView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        stackView.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 20).isActive = true
        
        stackView.widthAnchor.constraint(equalTo: self.view.widthAnchor, multiplier: 0.9).isActive = true
//        featureDetails.widthAnchor.constraint(equalTo: self.view.widthAnchor, multiplier: 0.8).isActive = true
        
    }
    
    @objc func backAction(){
        self.dismiss(animated: true, completion: nil)
    }
    
  
    @objc func doneAction(){
        
        if((self.featureTitle.text ?? "").count < 5){
            self.featureTitle.shake()
            return
        }
        
        
        var aFeature = DFFeature()
        aFeature.title = self.featureTitle.text
        aFeature.details = self.featureDetails.text
        
        
        self.delegate?.sendANewFeature(feature: aFeature)
        self.dismiss(animated: true, completion: nil)
    }
    
    
}

extension UIView {
      func shake() {
          let animation = CAKeyframeAnimation(keyPath: "transform.translation.x")
          animation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.linear)
          animation.duration = 0.3
          animation.values = [ -10.0, 10.0, -5.0, 5.0, 0.0 ]
          layer.add(animation, forKey: "shake")
      }
  }
  

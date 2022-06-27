//
//  Meezan.swift
//  DailyAthkar
//
//  Created by badi3 on 4/6/19.
//  Copyright © 2019 Badi3.com. All rights reserved.
//

import Foundation
import FirebaseFirestore
import FirebaseAuth
import FirebaseDynamicLinks
import FirebaseUI

enum CustomError: Error {
    case unknownError
    case realSignInNeeded
}

class Meezan {
    typealias commonCompletion = (_ success : Bool, _ error: Error?)->()
    typealias stringCompletion = (_ value : String?, _ error: Error?)->()
    
    static var authUI : FUIAuth? = FUIAuth.defaultAuthUI()

    static func loginWithPhone(viewController : UIViewController){
        let phoneProvider = FUIPhoneAuth.init(authUI: FUIAuth.defaultAuthUI()!)
        //FUIAuth.defaultAuthUI()?.providers = [phoneProvider]
        self.authUI?.providers = [phoneProvider] // NEEDED!?

        phoneProvider.signIn(withDefaultValue: nil, presenting: viewController) { (credential, error, callBack, userInfo)in

            if let error = error as NSError? {
                callBack?(nil, error)
                return
            }
            if let credential = credential,let user = Auth.auth().currentUser {
                
                
                user.linkAndRetrieveData(with: credential) { (authResult, error) in
                    
                    if let error = error as NSError? {
                        switch(error.code){
                        case 17025:
                            //merging
                            let anonymousUser = Auth.auth().currentUser
                            Auth.auth().signInAndRetrieveData(with: credential) { (result, error) in
                                if let newUser = Auth.auth().currentUser, let anonymousUser = anonymousUser, newUser.uid != anonymousUser.uid {
                                    Meezan.getMyAppLaunchCount(userUID: anonymousUser.uid, completion: { (anonymousCount) in
                                        Meezan.recordTheAppLaunch(userUID: newUser.uid, incrementValue: anonymousCount, completion: { (success, error) in
                                            if(success){
                                                let anonymousUserUID = anonymousUser.uid
                                                anonymousUser.delete(completion: { (error) in
                                                    if(error == nil){
                                                        Meezan.deleteUser(userUID: anonymousUserUID)
                                                    }
                                                })
                                            }
                                        })
                                    })
                                }
                                
                            }
                            viewController.dismiss(animated: true, completion: nil)
                        default:
                            callBack?(nil, error)
                        }
                    }
                    callBack?(authResult?.user, nil)
                }
                
            }
        }
    }
    
    
    struct KEYS {
        static let usersCollectionName = "users"
        static let appLaunchesKeyName = "appLaunchesCount"
        static let inviteesLaunchCountName = "inviteesLaunchCount"
    }
    
    static func detectInvitationLoop(userID: String, inviterUID: String, detectInvitationLoopCompletion : @escaping (_ goodNews : Bool)->Void){
        if(userID == inviterUID){
            detectInvitationLoopCompletion(false)
        }else{
            let db = Firestore.firestore()
            var invitersList : [String] = [userID]
            
            func getInviterThreadOfRef(ref: DocumentReference, inviterThreadCompletion: @escaping (_ goodNews : Bool)->Void ){
                ref.getDocument { (snapshot, error) in
                    invitersList.append(ref.documentID)
                    let hasDuplicates = invitersList.count != Set(invitersList).count

                    if(hasDuplicates){
                        print("invitersList \(invitersList)")
                        
                        inviterThreadCompletion(false)
                        return
                    }
                    
                    if let inviterInviter = snapshot?.data()?["inviter"] as? DocumentReference{
                        print("inviterInviter \(inviterInviter)")
                        getInviterThreadOfRef(ref: inviterInviter, inviterThreadCompletion: inviterThreadCompletion)
                    }else{
                        inviterThreadCompletion(true)

                    }
                }
            }
            
            let inviterRef = db.collection(KEYS.usersCollectionName).document(inviterUID)
            
            getInviterThreadOfRef(ref: inviterRef) { goodNews in
               detectInvitationLoopCompletion(goodNews)
            }
            
            
        }
    }
    
    static func registerMyInviter(inviterUID : String){
        

        
        func regisrationFunc(userID : String) {
            
            self.detectInvitationLoop(userID: userID, inviterUID: inviterUID) { noLoop in
                if(noLoop){
                    print("no loop detected")
                    
                    let db = Firestore.firestore()
                    let userRef = db.collection(KEYS.usersCollectionName).document(userID)
                    
                    userRef.getDocument(completion: { (snapshot, error) in
                        if (snapshot?.data()?["inviter"] as? DocumentReference) != nil{
                            print("alreadyExistingInviter")
                        }else{
                            let inviterRef = db.collection(KEYS.usersCollectionName).document(inviterUID)
                            userRef.setData(["inviter" : inviterRef], merge: true)
                        }
                    })
                    

                    
                }else{
                    print("Wait, there is a loop")
                    
                }
            }
            
            
        }
        
        if let userID = Auth.auth().currentUser?.uid{
            regisrationFunc(userID: userID)
        } else{
            Auth.auth().signInAnonymously(completion: { (result, error) in                
                if let userID = Auth.auth().currentUser?.uid{
                    regisrationFunc(userID: userID)
                }
                
            })
        }
    }
    
    static func deleteUser(userUID : String){
        let db = Firestore.firestore()
        let userRef = db.collection(KEYS.usersCollectionName).document(userUID)
        userRef.delete()
    }

    static func recordTheAppLaunch(userUID : String, incrementValue : Int = 1, completion : commonCompletion? = nil){
        
        let db = Firestore.firestore()

        func updateInviters(aTempUserID : String){
            let aTempUserRef = db.collection(KEYS.usersCollectionName).document(aTempUserID)
            aTempUserRef.getDocument { (snapshot, error) in
                if let inviter = snapshot?.data()?["inviter"] as? DocumentReference{
                    inviter.updateData(["inviteesLaunchCount" : FieldValue.increment(Int64(incrementValue))])
                    updateInviters(aTempUserID: inviter.documentID)
                }
            }
        }
        
        
        let userRef = db.collection(KEYS.usersCollectionName).document(userUID)
        userRef.updateData([KEYS.appLaunchesKeyName: FieldValue.increment(Int64(incrementValue))]) { (error) in
            
            guard let error = error as NSError? else {
                print("\(KEYS.appLaunchesKeyName) updated")
                updateInviters(aTempUserID: userUID)
                completion?(true, nil)
                return
            }
            
            if(error.code == 5){
                userRef.setData([KEYS.appLaunchesKeyName: 1 ], merge: true, completion: { (error) in
                    if (error == nil) {
                        print("\(KEYS.appLaunchesKeyName) set")
                        updateInviters(aTempUserID: userUID)
                        completion?(true, nil)
                        return
                    }
                })
            }
        }
    }
    
    static func getMyAppLaunchCount(userUID : String, completion : @escaping (_ count: Int)->()){
        let db = Firestore.firestore().collection(KEYS.usersCollectionName)
        let myReference = db.document(userUID)
        
        myReference.getDocument { (snapShot, error) in
            let count : Int = (snapShot?.data()?[KEYS.appLaunchesKeyName] as? Int) ?? 0
            completion(count)

        }
    }
    
    static func getMyInviteesTotalCount(userUID : String, completion : @escaping (_ count: Int)->()){
        let db = Firestore.firestore().collection(KEYS.usersCollectionName)
        let myReference = db.document(userUID)
        
        myReference.getDocument { (snapshot, error) in
            if let snapshot = snapshot, let data = snapshot.data(){
                let count = (data[KEYS.inviteesLaunchCountName] as? Int) ?? 0
                completion(count)

            }else{
                completion(0)
            }
        }
        
//        db.whereField(KEYS.inviterKeyName, isEqualTo: myReference).getDocuments { (snapShot, error) in
//            var total : Int = 0;
//            snapShot?.documents.forEach({ (oneDoc) in
//                total = total + (oneDoc.data()[KEYS.appLaunchesKeyName] as? Int ?? 0)
//
//
//            })
//            completion(total)
//        }
    }
    
    static func getMyInvitationLink(withoutLogin:Bool = false ,completion : @escaping stringCompletion){
        
        if let currentUser = Auth.auth().currentUser, (!currentUser.isAnonymous || withoutLogin){
            let linkParamter = URL.init(string: "https://athkar.app?type=invite&uid=\(currentUser.uid)")!
            
            if let shareLink = DynamicLinkComponents.init(link: linkParamter, domainURIPrefix: "https://athkar.page.link"){
                shareLink.iOSParameters = DynamicLinkIOSParameters(bundleID: "com.devanova.dailyathkar")
                shareLink.iOSParameters!.appStoreID = "821664774"

                shareLink.socialMetaTagParameters = DynamicLinkSocialMetaTagParameters()
                shareLink.socialMetaTagParameters?.title = "Athkar App - تطبيق الأذكار"
                shareLink.socialMetaTagParameters?.descriptionText = "Read or listen to Athkar - إقرأ أو استمع للأذكار"
                
                
                if let longURL = shareLink.url{
                    print("long url \(longURL.absoluteString)")
                }
                
                shareLink.shorten { (url, warnings, error) in
                    warnings?.forEach({ (warning) in
                        print("warning \(warning)")
                    })
                    
                    if let url = url{
                        print("url \(url.absoluteString)")
                        completion(url.absoluteString, nil)
                    }
                }

            }
            
            
        }else{
            print("should sign in")
            let errorTemp = NSError(domain:"", code:401, userInfo:nil)
            completion(nil, errorTemp)
            
        }
    }
}

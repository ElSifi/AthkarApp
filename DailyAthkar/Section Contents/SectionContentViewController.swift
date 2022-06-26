//
//  SectionContentViewController.swift
//  DailyAthkar
//
//  Created by Mohamed ElSIfi on 5/1/18.
//  Copyright © 2018 Badi3.com. All rights reserved.
//

import UIKit
import SwipeCellKit
import AVFoundation
import MediaPlayer
import StoreKit


class SectionContentViewController: UIViewController,
                                    UITableViewDelegate,
                                    UITableViewDataSource,
                                    SwipeTableViewCellDelegate,
                                    AVAudioPlayerDelegate,
                                    UIGestureRecognizerDelegate,
                                    UIScrollViewDelegate,
                                    ThikrTableViewCellDelegate,
                                    Storyboarded
{
    
    var audioPlayer : AVAudioPlayer?
    
    @IBOutlet weak var playPauseButton: UIButton!{
        didSet{
            playPauseButton.setTitle("play".localized, for: .normal)
            
        }
    }
    @IBOutlet weak var prevButton: UIButton!{
        didSet{
            prevButton.setTitle("previous".localized, for: .normal)
        }
    }
    @IBOutlet weak var nextButton: UIButton!{
        didSet{
            nextButton.setTitle("next".localized, for: .normal)
            
        }
    }
    
    
    @IBOutlet weak var topTitle: UILabel!
    @IBOutlet weak var backButton: UIButton!{
        didSet{
            if(LanguageManager.isCurrentLanguageRTL()){
                backButton.setImage(#imageLiteral(resourceName: "rightBack"), for: .normal)
            }else{
                backButton.setImage(#imageLiteral(resourceName: "leftBack"), for: .normal)
                
            }
        }
    }
    
    @IBOutlet weak var bgImage: UIImageView!{
        didSet{
            bgImage.image = theBGImage
        }
    }
    
    
    
    var viewModel : AthkarSectionDetailsViewModel!
    @IBOutlet weak var tableContainer: UIView!
    @IBOutlet weak var theTable: UITableView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        doUI()
        navigationController?.interactivePopGestureRecognizer?.delegate = self
        setupCommandCenter()
    }
    
    //to enable swipe to dismiss UINavigationController thing
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        if(navigationController!.viewControllers.count > 1){
            return true
        }
        return false
    }
    
    var requstedReview = false
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.y >= (scrollView.contentSize.height - scrollView.frame.size.height) {
            if(!requstedReview){
                SKStoreReviewController.requestReview()
                requstedReview = true
            }
        }
    }
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        self.nextAction(self.nextButton)
    }
    
    
    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        self.updatePlayerUI()
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        self.updatePlayerUI()
        
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate {
            self.updatePlayerUI()
        }
    }
    
    @IBAction func prevAction(_ sender: UIButton) {
        let toPlayIndex = currentPlayingThikrIndex - 1
        if(toPlayIndex >= 0){
            currentPlayingThikrIndex = toPlayIndex
            if(!playCurrentThikr()){
                prevAction(self.prevButton)
            }
        }
    }
    @IBAction func playPauseAction(_ sender: UIButton) {
        if let player = self.audioPlayer{
            if(player.isPlaying){
                player.pause()
            }else{
                player.play()
            }
            updatePlayerUI()
        }else{
            playAthkarList(passedAthkarToPlay: self.viewModel.athkarList)
        }
    }
    func getThikrViewModelIndex(thikrViewModel : ThikrCellViewModel)->Int{
        for (index, aThikr) in self.viewModel.athkarList.enumerated() {
            if(aThikr.zPk == thikrViewModel.zPk){
                return index
            }
        }
        
        return 0
    }
    
    func updatePlayerUI(){
        
        for cell in self.theTable.visibleCells {
            if let theCell = cell as? ThikrTableViewCell, let data = theCell.data{
                if
                    (
                        !athkarToPlay.isEmpty
                        && self.audioPlayer != nil
                        && self.audioPlayer!.isPlaying
                        && data.zPk == athkarToPlay[currentPlayingThikrIndex].zPk
                    )
                {
                    theCell.isAudioPlaying = true
                }else{
                    theCell.isAudioPlaying = false
                }
            }
        }
        
        
        let nextToPlayIndex = currentPlayingThikrIndex + 1
        if(nextToPlayIndex < self.athkarToPlay.count){
            self.nextButton.alpha = 1
        }else{
            self.nextButton.alpha = 0.5
            
        }
        
        
        let previousToPlayIndex = currentPlayingThikrIndex - 1
        if(previousToPlayIndex >= 0){
            self.prevButton.alpha = 1
        }else{
            self.prevButton.alpha = 0.5
        }
        
        if let thePlayer = self.audioPlayer, thePlayer.isPlaying{
            self.playPauseButton.setTitle("stop".localized, for: .normal)
        }else{
            self.playPauseButton.setTitle("play".localized, for: .normal)
        }
    }
    
    func playCurrentThikr() -> Bool{
        
        let thikr = athkarToPlay[currentPlayingThikrIndex]
        
        if let path = Utils.getPathForSoundFileForThikr(thikr: thikr, sectionID: self.viewModel!.stringID){
            let thikrIndex = getThikrViewModelIndex(thikrViewModel: thikr)
            let indexPath = IndexPath.init(row: thikrIndex, section: 0)
            
            let cellRect = theTable.rectForRow(at: indexPath)
            let completelyVisible = theTable.bounds.contains(cellRect)
            if(!completelyVisible){
                self.theTable.scrollToRow(at: indexPath, at: UITableView.ScrollPosition.none, animated: true)
            }
            
            
            
            let url = URL.init(fileURLWithPath: path)
            
            do{
                
                try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
                
                try AVAudioSession.sharedInstance().setActive(true)
                
                self.audioPlayer = try AVAudioPlayer.init(contentsOf: url)
                self.audioPlayer?.delegate = self
                self.audioPlayer?.prepareToPlay()
                self.audioPlayer?.play()
                UIApplication.shared.beginReceivingRemoteControlEvents()
                MPNowPlayingInfoCenter.default().nowPlayingInfo = [
                    MPMediaItemPropertyTitle: thikr.textArUnsigned,
                    MPMediaItemPropertyAlbumTitle: self.viewModel!.stringID,
                    MPMediaItemPropertyArtist: "mishary".localized
                ]
            }
            catch{
                print("error \(error)")
                
                return false
            }
            
            updatePlayerUI()
            return true
        }else{
            
            return false
        }
    }
    var athkarToPlay : [ThikrCellViewModel] = []
    var currentPlayingThikrIndex = 0
    func playAthkarList(passedAthkarToPlay : [ThikrCellViewModel]){
        self.athkarToPlay = passedAthkarToPlay
        self.currentPlayingThikrIndex = 0
        if(!playCurrentThikr()){
            nextAction(self.nextButton)
        }
    }
    
    
    
    @IBAction func nextAction(_ sender: UIButton) {
        let toPlayIndex = currentPlayingThikrIndex + 1
        if(toPlayIndex < self.athkarToPlay.count){
            currentPlayingThikrIndex = toPlayIndex
            if(!playCurrentThikr()){
                nextAction(self.nextButton)
            }
        }else{
            athkarToPlay = []
            currentPlayingThikrIndex = 0
            self.audioPlayer = nil
            updatePlayerUI()
        }
        
    }
    
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
        
        switch orientation {
        case .left:
            let onlyOne = SwipeAction(style: .default, title: nil) {[weak self] action, indexPath in
                let cell = tableView.cellForRow(at: indexPath) as! ThikrTableViewCell
                cell.hideSwipe(animated: true, completion: {[weak self] (completed) in
                    if let mySelf = self{
                        let subArray = mySelf.viewModel.athkarList[indexPath.row...indexPath.row]
                        mySelf.playAthkarList(passedAthkarToPlay: Array(subArray))
                    }
                })
                
            }
            
            onlyOne.image = #imageLiteral(resourceName: "play_current").maskWith(color: UIColor.init(hexString: "#211f1d"))
            onlyOne.backgroundColor = .clear//UIColor.init(hexString: "#211f1d").withAlphaComponent(0.1)
            
            let all = SwipeAction(style: .default, title: nil) {[weak self] action, indexPath in
                let cell = tableView.cellForRow(at: indexPath) as! ThikrTableViewCell
                cell.hideSwipe(animated: true, completion: {[weak self] (completed) in
                    if let mySelf = self{
                        let subArray = mySelf.viewModel.athkarList[indexPath.row...mySelf.viewModel.athkarList.count - 1]
                        mySelf.playAthkarList(passedAthkarToPlay: Array(subArray))
                    }
                })
            }
            
            all.backgroundColor = .clear//UIColor.init(hexString: "#211f1d").withAlphaComponent(0.1)
            all.image = #imageLiteral(resourceName: "play_till_end").maskWith(color: UIColor.init(hexString: "#211f1d"))
            
            
            return [onlyOne, all]
        case .right:
            let share = SwipeAction(style: .default, title: nil) {[weak self] action, indexPath in
                let cell = tableView.cellForRow(at: indexPath) as! ThikrTableViewCell
                cell.hideSwipe(animated: true, completion: {[weak self] (completed) in
                    if let mySelf = self{
                        mySelf.saveAsImage(indexPath: indexPath)
                    }
                })
            }
            
            share.image = #imageLiteral(resourceName: "share").maskWith(color: UIColor.init(hexString: "#211f1d"))
            share.backgroundColor = .clear//UIColor.init(hexString: "#211f1d").withAlphaComponent(0.1)
            
            
            
            return [share]
        }
        
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        let x : Int
        x = 5
        
        func x(){
            print("xx")
        }
        
        if(!(StringKeys.UserDidSwipeForAudio.savedValue as? Bool ??  false)){
            if let cell = self.theTable.visibleCells.first{
                if let swipeCell = cell as? ThikrTableViewCell{
                    swipeCell.showSwipe(orientation: .left, animated: true) { (completed) in
                        StringKeys.UserDidSwipeForAudio.saveValue(value: true)
                    }
                }
                
            }
        }else if(!(StringKeys.UserDidSwipeForSharing.savedValue as? Bool ??  false)){
            if let cell = self.theTable.visibleCells.first{
                if let swipeCell = cell as? ThikrTableViewCell{
                    swipeCell.showSwipe(orientation: .right, animated: true) { (completed) in
                        StringKeys.UserDidSwipeForSharing.saveValue(value: true)
                    }
                }
                
            }
        }
        
        
    }
    
    func saveAsImage(indexPath : IndexPath){
        
        let thikr = self.viewModel.athkarList[indexPath.row]
        
        let shareView =  UINib(nibName: "ShareView", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! ShareView
        
        
        shareView.bounds = CGRect.init(x: 0, y: 0, width: 600, height: 400)
        
        let blurEffect = UIBlurEffect(style: UIBlurEffect.Style.light)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = shareView.textContainer.bounds
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        shareView.textContainer.insertSubview(blurEffectView, at: 0)
        
        
        shareView.thirkLabel.text = "thikr[Utils.getThikrTextKey()].stringValue"
        shareView.thirkLabel.numberOfLines = 0
        shareView.thirkLabel.textAlignment = .center
        shareView.thirkLabel.font = DA_STYLE.savedFont.withSize(50)
        shareView.thirkLabel.adjustsFontSizeToFitWidth = true
        shareView.thirkLabel.sizeToFit()
        
        shareView.titleLabel.text = self.topTitle.text
        
        
        let renderer = UIGraphicsImageRenderer(size: shareView.bounds.size)
        let image = renderer.image { ctx in
            shareView.drawHierarchy(in:shareView.bounds, afterScreenUpdates: true)
        }
        let imageToShare : [Any] = [image]
        let activityViewController = UIActivityViewController(activityItems: imageToShare, applicationActivities: nil)
        activityViewController.popoverPresentationController?.sourceView = self.theTable.cellForRow(at: indexPath) // so that iPads won't crash
        self.present(activityViewController, animated: true, completion: nil)
    }
    
    
    
    func tableView(_ tableView: UITableView, editActionsOptionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> SwipeTableOptions {
        var options = SwipeTableOptions()
        options.expansionStyle = .none
        options.transitionStyle = .drag
        options.backgroundColor = UIColor.clear
        return options
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.viewModel.athkarList.count
    }
    func playSoundOfThikrViewModel(thikrViewModel: ThikrCellViewModel) {
        
        let index = getThikrViewModelIndex(thikrViewModel: thikrViewModel)
        
        if
            (
                !athkarToPlay.isEmpty
                && self.audioPlayer != nil
                && thikrViewModel.zPk == athkarToPlay[currentPlayingThikrIndex].zPk
            )
        {
            if(self.audioPlayer!.isPlaying){
                self.audioPlayer!.pause()
            }else{
                self.audioPlayer!.play()
            }
        }else{
            let subArray = self.viewModel.athkarList[index...self.viewModel.athkarList.count - 1]
            self.playAthkarList(passedAthkarToPlay: Array(subArray))
            
        }
        
        updatePlayerUI()
        
        
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "thikr") as! ThikrTableViewCell
        cell.delegate = self
        cell.athkarDelegate = self
        let thikr = self.viewModel.athkarList[indexPath.row]
        
        
        if
            (
                !athkarToPlay.isEmpty
                && self.audioPlayer != nil
                && self.audioPlayer!.isPlaying
                && getThikrViewModelIndex(thikrViewModel: athkarToPlay[currentPlayingThikrIndex]) == indexPath.row
            )
        {
            cell.isAudioPlaying = true
        }else{
            cell.isAudioPlaying = false
        }
        
        
        
        let athkarData = thikr
        
        
        let maxCount = thikr.repeatTimes
        let currentCount = thikr.currentCount
        
        cell.leftRepeatLabel.text = String.init(describing: currentCount)
        cell.middleRepeatLabel.text = " \("of".localized) \(maxCount) "
        cell.rightRepeatLabel.text = "\("times".localized)"
        
        
        
        cell.data = athkarData
        
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if(self.viewModel.athkarList[indexPath.row].currentCount < self.viewModel.athkarList[indexPath.row].repeatTimes)
        {
            self.viewModel.athkarList[indexPath.row].currentCount = self.viewModel.athkarList[indexPath.row].currentCount + 1
            tableView.reloadRows(at: [indexPath], with: .fade)
        }
    }
    
    
    func doUI(){
        theTable.rowHeight = UITableView.automaticDimension
        theTable.estimatedRowHeight = 100
        tableContainer.layer.cornerRadius = 6
        tableContainer.clipsToBounds = true
        let blurEffect = UIBlurEffect(style: UIBlurEffect.Style.regular)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = tableContainer.bounds
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        tableContainer.insertSubview(blurEffectView, at: 0)
        
        self.topTitle.text = self.viewModel!.localizedName
        self.topTitle.font = DA_STYLE.savedFont.withSize(26)
    }
    
    
    @IBAction func goBack(_ sender: Any) {
        _ = self.navigationController?.popViewController(animated: true)
    }
    
    fileprivate func setupCommandCenter() {
        let commandCenter = MPRemoteCommandCenter.shared()
        commandCenter.playCommand.isEnabled = true
        commandCenter.pauseCommand.isEnabled = true
        commandCenter.playCommand.addTarget { [weak self] (event) -> MPRemoteCommandHandlerStatus in
            self?.audioPlayer?.play()
            self?.updatePlayerUI()
            print("play")
            return .success
        }
        commandCenter.pauseCommand.addTarget { [weak self] (event) -> MPRemoteCommandHandlerStatus in
            self?.audioPlayer?.pause()
            self?.updatePlayerUI()
            print("pause")
            return .success
        }
        
        commandCenter.nextTrackCommand.addTarget { [weak self] (event) -> MPRemoteCommandHandlerStatus in
            print("nextTrackCommand")
            self?.nextAction((self?.nextButton)!)
            return .success
        }
        
        commandCenter.previousTrackCommand.addTarget { [weak self] (event) -> MPRemoteCommandHandlerStatus in
            print("previousTrackCommand")
            self?.prevAction((self?.prevButton)!)
            return .success
        }
    }
    
}

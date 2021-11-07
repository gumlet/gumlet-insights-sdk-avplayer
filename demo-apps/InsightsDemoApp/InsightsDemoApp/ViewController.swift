//
//  ViewController.swift
//  GumletVideoAnalytics
//

//

import UIKit
import AVKit
import AVFoundation
import GumletInsightsAVPlayer
//import GumletSDKVidAnalytics


@available(iOS 13.0, *)
class ViewController: UIViewController {
    
   
    var playerVC = AVPlayerViewController()
    let video_url_one = "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ElephantsDream.mp4"
   var activityView: UIActivityIndicatorView?

    
    override func viewDidLoad() {
        super.viewDidLoad()
      
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
       
        hideActivityIndicator()

    }
    
    
    
    
    @IBAction func playVideoOne(_ sender:Any)
    {
        showActivityIndicator()
        
        let videoURL = NSURL(string:video_url_one)
        let player = AVPlayer(url: videoURL! as URL)
        playerVC.player = player
        self.present(playerVC, animated: true) {
            self.playerVC.player!.play()
    }
       
        //Add PropertyId
        var gumletConfig = GumletInsightsConfig()
        gumletConfig.proprtyId = "G8l9IeDh" //Get new Property Id from dashboard.
        
        //Add playerData
        var playerData = GumletInsightsCustomPlayerData()
        playerData.gumletPageType = "AVPlayerViewController"
        playerData.GumletPlayerIntegrationVersion = "1.0.0"
        playerData.GumletPlayerName = "AVPlayer"
        
        //Add videoData
        var videoData = GumletInsightsCustomVideoData();
        videoData.customVideotitle = "peppa pig";
        videoData.customVideoId = "123"
        videoData.customVideoProducer = "Jhon Peppa"
        
        //Add userData
        var userData = GumletInsightsUserData()
        userData.userName = "Den Brown"
        userData.userEmail = "DenBrown@gmail.com"
        userData.userCountry = "United Kingdom"
     
        //Add Gumlet video analytics SDK init method
        GumletInsightsSDK.initAVPlayerViewController(playerVC, userData:userData, customVideoData:videoData, customPlayerData: playerData, config: gumletConfig)
    }
    
   
    
    func showActivityIndicator() {
        activityView = UIActivityIndicatorView(style: .large)
        activityView?.center = self.view.center
        self.view.addSubview(activityView!)
        activityView?.startAnimating()
    }
    
    func hideActivityIndicator(){
        if (activityView != nil){
            activityView?.stopAnimating()
        }
    }
    
    
    
}

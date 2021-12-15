//
//  ViewController.swift
//  GumletVideoAnalytics
//

//

import UIKit
import Foundation
import AVKit
import AVFoundation
import SystemConfiguration
import Security
import MachO
import WebKit


public class AVPlayerCore: NSObject {
    
    // MARK:- constants
    let GumletPlayerSoftwareAVPlayerViewController = "AVPlayerViewController"
    
    let playerLanguageCode = "Swift"
    
    // Min number of seconds between timeupdate events. (100ms)
    let GumletMaxSecsBetweenTimeUpdate :Double = 0.1;
    var lastUpdateTime :Float = 0.0
    var timeOfUpdate :CFAbsoluteTime = 0.0
    
    let eventUpdatePlaybackTime = 3.0
    
    var sessionId :String = ""
    var uniqueId :String = ""
    var meta_CDN :String = ""
    var meta_device_Arch :String = ""
    var videoSourceType : String = ""
    var videoSourceUrl : String = ""
    var eventName : String = ""
    var previousEvents: String = ""
    var bitrates:String = ""
    var playBackId : String = ""
    var eventId : String = ""
    var playerInstanceId : String = ""
    var networkRequestId : String = ""
    var state : String = ""
    var playerLanguage : String = ""
    var deviceOrientation :String = ""
    var playerName:String = ""
    var prevDeviceOrientation : String = ""
    var timeObservation: Any!
    
    var localCurrentTime : Int = 0
    var aspectRatio: CGFloat!
    var indicatedBitrate:Float = 0.0
    var videoWidth : Float = 0.0
    var videoHeight :Float = 0.0
    var player_width:Float = 0.0
    var player_height:Float = 0.0
    var screenWidth:Int = 0
    var screenHeight:Int = 0
    var play_current_time:Double = 0.0
    var pause_current_time:Double = 0.0
    var videoTotalTime :Double = 0.0
    public var currentTimeEpoch : Double = 0.0
    
    var _lastTransferEventCount : Int8 = 0
    var _lastTransferDuration : Double = 0.0
    var _lastTransferredBytes : Int64 = 0
    
    
    
    var isBuffer :Bool = false
    var isSeeking :Bool = false
    var isOrientationChange: Bool = false
    var isEventsetup : Bool = true
    var isQualitychange :Bool = false
    var isVideoQualityChange : Bool = false
    var isVideoChange : Bool =  false
    
    var videoMuted :Bool = false
    var videoUnMuted : Bool = false
    var isFullScreen :Bool = false
    public var isPlaybackStarted :Bool = true
    var isplaybackFinish :Bool = false
    var isorientationFirst : Bool = true
    var isSessionId : Bool = true
   public var eventCollection : [String] = ["event_player_setup",
                                                                "event_player_ready",
                                                                "event_play",
                                                                "event_playing",
                                                                "event_rebuffer_start",
                                                                "event_rebuffer_end",
                                                                "event_paused","event_end","event_video_change","event_device_orientation_changed","event_quality_change"]
    public var eventArr : [String] = []

    
    var errorTitle:String = ""
    var errorMessage:String = ""
    var errorCode = 0
    
    // init Gumlet Video Manager
    var videAnaManager = GumletInsightsManager()
    let gumletTranstion = GumletTransition(states: GumletPlayerStateMachine.GumletPlayerStateViewinit.rawValue)
    // init player
    var player = AVPlayer()
    let controller = AVPlayerViewController()
    //    var currentItem = AVPlayerItem?()
    var currentPlayerItem: AVPlayerItem?
    var timer = Timer()
    var webViewForUserAgent: WKWebView?
    

   
    //MARK:- Id's collection
    func callIds()
    {
       
        sessionId = checkSessionId()
        checkUniqueId()
        checkPlayBackId()
        checkPlayerInstanceId()
        networkRequestId = createNetworkRequestId()
        eventId = createEventId()
        
    }
    
    func createSessionId() -> String
    {
        let session_Id = UUID().uuidString
        print("session_Id:-\(session_Id)")//8qBBjceMo8
     


        UserDefaults.standard.setValue(session_Id, forKey: "user_session")
        UserDefaults.standard.set(Date(), forKey:"user_session_creation_time")
        UserDefaults.standard.set("", forKey: "backgroundCurrentTime")
        UserDefaults.standard.set("",  forKey:"foregroundCurrentTime")
        return session_Id
    }
    
   public func checkSessionId() -> String
    {
            if let session_id = UserDefaults.standard.string(forKey: "user_session") {
            print("session_ID:-\(session_id)")
            if let date = UserDefaults.standard.object(forKey: "user_session_creation_time")as? Date {
                print("date:-\(date)")
                
                let backgroundCurrentTime = UserDefaults.standard.object(forKey: "backgroundCurrentTime")as? Date
                let foregroundCurrentTime = UserDefaults.standard.object(forKey: "foregroundCurrentTime")as? Date
                print("backgroundCurrentTime:-\(String(describing: backgroundCurrentTime))")
                print("foregroundCurrentTime:-\(String(describing: foregroundCurrentTime))")
                if backgroundCurrentTime == nil && foregroundCurrentTime == nil{
                    print("nil")
                    if let diff = Calendar.current.dateComponents([.minute], from: date, to: Date()).minute, diff > 30
                    {
                        print("diff:-\(diff)")
                        return createSessionId()
                    }
                }else if foregroundCurrentTime == nil
                {
                    print("nil")
                }
                else if backgroundCurrentTime == nil
                {
                    print("nil")
                }
                else
                {
                    let diff = Calendar.current.dateComponents([.minute], from: backgroundCurrentTime!, to: foregroundCurrentTime!).minute
                    print("diff:\(String(describing: diff))")
                    if  diff! > 30
                    {
                        print("diff:-\(String(describing: diff))")
                        return createSessionId()
                        
                    }
                    else{
                        if diff! > 30 + diff!
                        {
                            print("session_id:-\(session_id)")
                        }
                    }
                }
            }
            return session_id
            
        }
        else{
            //print("create session")
            return createSessionId()
        }
    }
    
    public func createEventId() -> String
    {
        let event_id = UUID().uuidString
        
        return event_id
    }
    
   public func createNetworkRequestId() -> String
    {
        let request_id = UUID().uuidString
        
        return request_id
    }
    
    
    public func createPlayBackId() -> String
    {
        let play_back_id = UUID().uuidString
        savePlayBackId(playerId: play_back_id)
        return play_back_id
    }
    func savePlayBackId(playerId:String)
    {
        UserDefaults.standard.setValue(playerId, forKey: "playBackId")
    }
    
    func loadPlayBackId()
    {
        playBackId = UserDefaults.standard.value(forKey: "playBackId") as! String
        
        
    }
    func checkPlayBackId()
    {
        if UserDefaults.standard.value(forKey: "playBackId")  == nil
        {
            playBackId = createPlayBackId()
        }
        else{
            loadPlayBackId()
        }
    }
    public func createPlayerInstanceId() -> String
    {
        let player_instance_id = UUID().uuidString
        savePlayerInstanceId(playerInstanceId: player_instance_id)
        return player_instance_id
    }
    func savePlayerInstanceId(playerInstanceId:String)
    {
        UserDefaults.standard.setValue(playerInstanceId, forKey: "PlayerInstanceId")
    }
    
    func loadPlayerInstanceId()
    {
        playerInstanceId = UserDefaults.standard.value(forKey: "PlayerInstanceId") as! String
        
        
    }
    func checkPlayerInstanceId()
    {
        if UserDefaults.standard.value(forKey: "PlayerInstanceId")  == nil
        {
            playerInstanceId = createPlayerInstanceId()
        }
        else{
            loadPlayerInstanceId()
        }
    }
    
    //MARK:- unique Id
   public func createUniqueId() -> String
    {
        let userId = UIDevice.current.identifierForVendor!.uuidString

        
        saveUniqueId(uniqueId:userId)
        return userId
    }
    func saveUniqueId(uniqueId:String)  {
        UserDefaults.standard.setValue(uniqueId, forKey: "user_id")
    }
    func loadUniqueId()  {
        uniqueId = UserDefaults.standard.value(forKey: "user_id") as! String
    }
    
    func checkUniqueId()
    {
        if UserDefaults.standard.value(forKey: "user_id")  == nil
        {
            uniqueId = createUniqueId()
        }
        else{
            loadUniqueId()
        }
    }
    
    
    
    //MARK:- Setup Player
    
    
    
    public func setupPlayer(playerAV:AVPlayer, propertyId:String)
    {
       
        self.player = playerAV
        
        currentPlayerItem = player.currentItem
        
        init_SDK(propertyId: propertyId)
        
        let video_url: URL? = (player.currentItem?.asset as? AVURLAsset)?.url
        print("video_url:-\(String(describing: video_url))")
        callEventSetUp(videoURL: video_url!.absoluteString)
        
        
        self.player.addObserver(self, forKeyPath: "status", options: [.old, .new], context: nil)
        self.player.addObserver(self, forKeyPath: "rate", options: [.old, .new], context: nil)
        self.player.addObserver(self, forKeyPath: "timeControlStatus", options: [.old, .new], context: nil)
        
       
        
        
        NotificationCenter.default.addObserver(self, selector:#selector(self.playerDidFinishPlaying),name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: player.currentItem)
        //
        
        NotificationCenter.default.addObserver(self, selector:#selector(self.receiveAirPlayNotification(note:)),name: UIScreen.didConnectNotification, object: nil)
        
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(handleAVPlayerAccess),name: NSNotification.Name.AVPlayerItemNewAccessLogEntry,
                                               object: nil)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(handleAVPlayerError),name: NSNotification.Name.AVPlayerItemNewErrorLogEntry,
                                               object: nil)
        
        let notificationCenter = NotificationCenter.default
            notificationCenter.addObserver(self, selector: #selector(appMovedToBackground), name: UIApplication.didEnterBackgroundNotification, object: nil)
            
            notificationCenter.addObserver(self, selector: #selector(appCameToForeground), name: UIApplication.willEnterForegroundNotification, object: nil)
            

    }
    
    
    
    public func callEventSetUp(videoURL:String)
    {
        playBackId = UUID().uuidString
    
        UserDefaults.standard.setValue(playBackId, forKey: "playBackId")
        if let url = UserDefaults.standard.string(forKey: "video_url"), url != videoURL {
            
//            callVideoChange()
            isVideoChange = true
        }
        UserDefaults.standard.setValue(videoURL, forKey: "video_url")
        
       
        isPlaybackStarted = true
     
        state = gumletTranstion.transitionState(destinationState: GumletPlayerStateMachine.GumletPlayerStateViewinit.rawValue)
     
        isEventsetup = true
        
      
    
        eventName = Events.isPlayerSetup.rawValue
//      
        
        let prevEvents = ""
       
        
        UserDefaults.standard.setValue(eventName, forKey: "eventName")
        play_current_time = getPlay_Pause_Time()
      
        
        callEventsAPI(eventTime: play_current_time, previousEvents:prevEvents)
        
        if isVideoChange == true{
            
            callVideoChange()
        }
        
       
     
        
    }
    
    
    public func playerReady()
    {
        //print("Start to Play")
       
      state = gumletTranstion.transitionState(destinationState: GumletPlayerStateMachine.GumletPlayerStateReady.rawValue)

        
        isEventsetup = false
        
        eventName = Events.isPlayerReady.rawValue

        
        let prevEvents = UserDefaults.standard.value(forKey: "eventName") as! String
      
        
        
        UserDefaults.standard.setValue(eventName, forKey: "eventName")
        
        play_current_time = getPlay_Pause_Time()
      
        callEventsAPI(eventTime: play_current_time, previousEvents:prevEvents)
        
        
        DispatchQueue.main.async {
            let interval = CMTimeMakeWithSeconds(0.1, preferredTimescale: Int32(NSEC_PER_SEC))//CMTime(seconds: 1, preferredTimescale: 10)
            self.timeObservation = self.player.addPeriodicTimeObserver(forInterval: interval, queue: .main, using: { [weak self] time in
                guard let weakSelf = self else { return }
                
                weakSelf.checkForSeekEvent()
                weakSelf.checkVideoQualityChange()
                weakSelf.checkMuteAnUnmute()
                weakSelf.updateLastPlayheadTime()
                
            })
        }
        
    }
    
    public func callPlay()
    {
        

    
    
        state = gumletTranstion.transitionState(destinationState:GumletPlayerStateMachine.GumletPlayerStatePlay.rawValue)
       
        eventName = Events.isPlay.rawValue
        

        
        let prevEvents = UserDefaults.standard.value(forKey: "eventName") as! String
        UserDefaults.standard.setValue(eventName, forKey: "eventName")
        
        play_current_time = getPlay_Pause_Time()
        UserDefaults.standard.setValue(play_current_time, forKey: "play_current_time")
     
        callEventsAPI(eventTime: play_current_time, previousEvents:prevEvents)
    }
    
    public func callPlaying()
    {
        callSeekEvent()
        
        
       
        
        state = GumletPlayerStateMachine.GumletPlayerStatePlaying.rawValue
        eventName = Events.isPlaying.rawValue
        
       

        
        let prevEvents = UserDefaults.standard.value(forKey: "eventName") as! String
      
        UserDefaults.standard.setValue(eventName, forKey: "eventName")
        
        
        
        play_current_time = getPlay_Pause_Time()
      
        UserDefaults.standard.setValue(play_current_time, forKey: "seekedTime")
        callEventsAPI(eventTime: play_current_time, previousEvents:prevEvents)
      
        
        
        if isPlaybackStarted == true
        {
            callPlaybackStarted()
            isPlaybackStarted = false
        }
        
        
        updatePlaybackEvent()
        
        
        
        
        
    }
    
    public func callPause()
    {
        
        timer.invalidate()
        timer = Timer()
        

        
     
        
        state = gumletTranstion.transitionState(destinationState:GumletPlayerStateMachine.GumletPlayerStatePaused.rawValue)
        eventName = Events.isPaused.rawValue
        

        
        let prevEvents = UserDefaults.standard.value(forKey: "eventName") as! String
      
        
        UserDefaults.standard.setValue(eventName, forKey: "eventName")
        
        
        
        
        play_current_time = getPlay_Pause_Time()
   
        callEventsAPI(eventTime: play_current_time, previousEvents:prevEvents)
    }
    
    func callPlaybackStarted()
    {
        eventName = Events.isPlaybackStarted.rawValue
        let prevEvents = UserDefaults.standard.value(forKey: "eventName") as! String
        
        UserDefaults.standard.setValue(eventName, forKey: "eventName")
        
        play_current_time = getPlay_Pause_Time()
        UserDefaults.standard.setValue(play_current_time, forKey: "play_current_time")
       
        callEventsAPI(eventTime: 0.0, previousEvents:prevEvents)
    }

    
    public func callBufferingStart()
    {
        
        timer.invalidate()
        //print("Buffering Start")
        
        state = gumletTranstion.transitionState(destinationState:GumletPlayerStateMachine.GumletPlayerStateBuffering.rawValue)
        
        eventName = Events.isBufferingStart.rawValue
        eventCollection.append(eventName)
        
        var prevEvents :String? = ""
        
        if prevEvents != nil{
            
            prevEvents = (UserDefaults.standard.value(forKey: "eventName") as! String)
           
        }
        else{
            
            prevEvents = ""
        }
        
        UserDefaults.standard.setValue(eventName, forKey: "eventName")
        
        
        isBuffer = true
        
        play_current_time = getPlay_Pause_Time()
        callEventsAPI(eventTime: play_current_time, previousEvents:prevEvents!)
        
    }
    
    public func callBufferingEnd()
    {
       
        eventName = Events.isBufferingEnd.rawValue
        
        var prevEvents :String? = ""
       
        if prevEvents != nil{
            
            prevEvents = (UserDefaults.standard.value(forKey: "eventName") as! String)
           
        }
        else{
            
            prevEvents = ""
        }
        
        UserDefaults.standard.setValue(eventName, forKey: "eventName")
        
        play_current_time = getPlay_Pause_Time()
        callEventsAPI(eventTime: play_current_time, previousEvents:prevEvents!)
    }
    
    func callMute()
    {
        videoUnMuted = true
        
     
        eventName = Events.isMute.rawValue

        
        let prevEvents = UserDefaults.standard.value(forKey: "eventName") as! String
       
        
        UserDefaults.standard.setValue(eventName, forKey: "eventName")
        
        
        play_current_time = getPlay_Pause_Time()
       
        callEventsAPI(eventTime: play_current_time, previousEvents:prevEvents)
    }
    
    func callUnmute()
    {
       
        eventName = Events.isUnMute.rawValue

        
        let prevEvents = UserDefaults.standard.value(forKey: "eventName") as! String
     
        
        UserDefaults.standard.setValue(eventName, forKey: "eventName")
        
        
        play_current_time = getPlay_Pause_Time()
      
        callEventsAPI(eventTime: play_current_time, previousEvents:prevEvents)
    }
    
    func callFullScreenStart()
    {
       
        eventName = Events.isFullScreenStart.rawValue
        let prevEvents = UserDefaults.standard.value(forKey: "eventName") as! String
    
        
        UserDefaults.standard.setValue(eventName, forKey: "eventName")
        
        
        
        
        play_current_time = getPlay_Pause_Time()
    
        callEventsAPI(eventTime: play_current_time, previousEvents:prevEvents)
        
        
    }
    
    func callFullScreenEnd()
    {
        timer.invalidate()
        //print("callFullScreenEnd")
        eventName = Events.isFullScreenEnd.rawValue
        let prevEvents = UserDefaults.standard.value(forKey: "eventName") as! String
        //print("previousEvent:-----\(prevEvents)")
        
        UserDefaults.standard.setValue(eventName, forKey: "eventName")
        
        
        
        
        play_current_time = getPlay_Pause_Time()
       
        callEventsAPI(eventTime: play_current_time, previousEvents:prevEvents)
        
        
        
    }
    
    func callDeviceOrientation()
    {
       
        if (isOrientationChange == false)
        {
            isOrientationChange = true
            eventName = Events.isDeviceOrientationChange.rawValue
//            eventCollection.append(eventName)
            
            var prevEvents :String? = ""
        
            if prevEvents == ""{
                prevEvents = ""
            }
            
            else{
                
                
                prevEvents = (UserDefaults.standard.value(forKey: "eventName") as! String)
              
                
                
            }
            
            UserDefaults.standard.setValue(eventName, forKey: "eventName")
            
            
            
            
            play_current_time = getPlay_Pause_Time()
           
            callEventsAPI(eventTime: play_current_time, previousEvents:prevEvents!)
        }
        else if(isOrientationChange == true)
        {
            isOrientationChange = false
            eventName = Events.isDeviceOrientationChange.rawValue

            
            var prevEvents :String? = ""
            
            if prevEvents != nil{
                
                prevEvents = ""
            }
            else{
                
                prevEvents = (UserDefaults.standard.value(forKey: "eventName") as! String)
              
                
            }
            
            UserDefaults.standard.setValue(eventName, forKey: "eventName")
            
            
            
            
            play_current_time = getPlay_Pause_Time()
          
            callEventsAPI(eventTime: play_current_time, previousEvents:prevEvents!)
        }
        
    }
    
    
    func callScreenCastStart()
    {
        timer.invalidate()
     
        var prevEvents :String? = ""
        
        if prevEvents != nil{
            
            prevEvents = (UserDefaults.standard.value(forKey: "eventName") as! String)
            
        }
        else{
            
            prevEvents = ""
        }
        
        UserDefaults.standard.setValue(eventName, forKey: "eventName")
        
        
        play_current_time = getPlay_Pause_Time()
     
        callEventsAPI(eventTime: play_current_time, previousEvents:prevEvents!)
        
    }
    
    func callScreenCastEnd()
    {
        timer.invalidate()
       
        var prevEvents :String? = ""
        
        if prevEvents != nil{
            
            prevEvents = (UserDefaults.standard.value(forKey: "eventName") as! String)
           
        }
        else{
            
            prevEvents = ""
        }
        
        UserDefaults.standard.setValue(eventName, forKey: "eventName")
        
        
        
        play_current_time = getPlay_Pause_Time()
       
        callEventsAPI(eventTime: play_current_time, previousEvents:prevEvents!)
    }
    
    public func callVideoChange()
    {
        timer.invalidate()
      
        
        isVideoChange = false
        
        eventName = Events.isVideochange.rawValue

        
        var prevEvents :String? = ""
        
        if prevEvents != nil{

            prevEvents = (UserDefaults.standard.value(forKey: "eventName") as! String)
      
        }
        else{
            
            prevEvents = ""
      }
        
        UserDefaults.standard.setValue(eventName, forKey: "eventName")
        
        
        
        
        play_current_time = getPlay_Pause_Time()
      
        callEventsAPI(eventTime: play_current_time, previousEvents:prevEvents!)
        
        
      
        
    }
    
    
    func callVideoQualityChange()
    {
     
        
        isQualitychange = true
        isVideoQualityChange = true
    
        eventName = Events.isQualityChange.rawValue

        
        let prevEvents = UserDefaults.standard.value(forKey: "eventName") as! String
      
        
        UserDefaults.standard.setValue(eventName, forKey: "eventName")
        
        
        
        play_current_time = getPlay_Pause_Time()
       
        callEventsAPI(eventTime: play_current_time, previousEvents:prevEvents)
    }
    
    func callSeekEvent()
    {
        //print("seek:\(isSeeking)")
        if isSeeking == true
        {
            
                callSeekedEvent()

            isSeeking = false
        }
    }
    
    func callSeekedEvent()
    {
      
 
        eventName = Events.isSeek.rawValue

        
        var prevEvents :String? = ""
        let seekTime = getDate()
        UserDefaults.standard.setValue(seekTime, forKey: "seekTimeEnd")
        if prevEvents != nil{
            
            prevEvents = (UserDefaults.standard.value(forKey: "eventName") as! String)
         
        }
        else{
            
            prevEvents = ""
        }
        
        UserDefaults.standard.setValue(eventName, forKey: "eventName")
        
        let seekStartTime = UserDefaults.standard.value(forKey: "seekVideoStartTime")
       
        
        
        play_current_time = getPlay_Pause_Time()
        
        let seekedTime = play_current_time//total_time as! Double + 15.0
        
      
        callSeekEventsAPI(eventTime: play_current_time, previousEvents: prevEvents!, seekingTime: seekStartTime as! Double, seekedTime:seekedTime)
    }
    
    
    
    func callError() {
        
        
        state =  gumletTranstion.transitionState(destinationState:GumletPlayerStateMachine.GumletPlayerStateError.rawValue)
        if (player.error != nil)
        {
            let errCode = player.error! as NSError
            errorCode = errCode.code
            errorTitle = errCode.domain
            errorMessage = errCode.localizedDescription
        }else if ((currentPlayerItem != nil) && (currentPlayerItem?.error != nil)) {
            
            let errCode = (currentPlayerItem?.error)! as NSError
            errorMessage = errCode.localizedDescription
            errorCode = errCode.code
            errorTitle = errCode.domain
        }
        
        
        
        eventName = Events.isEventError.rawValue
        var prevEvents :String? = ""
        
        if prevEvents != nil{
            
            prevEvents = (UserDefaults.standard.value(forKey: "eventName") as! String)
            
        }
        else{
            
            prevEvents = ""
        }
        
        UserDefaults.standard.setValue(eventName, forKey: "eventName")
        
        
        isBuffer = true
        
        play_current_time = getPlay_Pause_Time()//Double(currentTime)
       
        callEventsAPI(eventTime: play_current_time, previousEvents:prevEvents!)
        
    }
    
    
    //MARK:-- update playback Event Timer
    func updatePlaybackEvent()
    {
        
        timer = Timer.scheduledTimer(timeInterval:eventUpdatePlaybackTime, target: self, selector: #selector(updateTimer), userInfo: nil, repeats: true)
        
    }
    
    
    @objc func updateTimer()
    {
        
        
        
        eventName = Events.isUpdatePlayback.rawValue
        
        let prevEvents = UserDefaults.standard.value(forKey: "eventName") as! String
      
        
        UserDefaults.standard.setValue(eventName, forKey: "eventName")
        
        
        
        
        play_current_time = getPlay_Pause_Time()
       
        callEventsAPI(eventTime: play_current_time, previousEvents:prevEvents)
        

    }
    
    
  
    
    @objc func appMovedToBackground() {
       print("app enters background")

        UserDefaults.standard.setValue(Date(), forKey: "backgroundCurrentTime")
   }

   @objc func appCameToForeground() {
       print("app enters foreground")
    

    UserDefaults.standard.setValue(Date(), forKey: "foregroundCurrentTime")
   }
    
    
    @objc func playerDidFinishPlaying(){
      
        
        isplaybackFinish = true
      
        state = gumletTranstion.transitionState(destinationState:GumletPlayerStateMachine.GumletPlayerStateViewEnd.rawValue)
        eventName = Events.isEnd.rawValue
        eventCollection.append(eventName)
        
        let prevEvents = UserDefaults.standard.value(forKey: "eventName") as! String
       
        
        UserDefaults.standard.setValue(eventName, forKey: "eventName")
        
        play_current_time = getPlay_Pause_Time()
     
        callEventsAPI(eventTime: play_current_time, previousEvents:prevEvents)
        
        
    }
    
   
    
    
    
    
    @objc func handleAVPlayerError(notification: Notification) {
        
        let isNotificationRelevant :Bool = checkIfNotificationIsRelevant(notif: notification as NSNotification)
       
        if (isNotificationRelevant) {
          
            let playerItem = notification.object as? AVPlayerItem
            let log:AVPlayerItemErrorLog? = playerItem!.errorLog() 
            
            if (log != nil && log!.events.count > 0)
            {
                // https://developer.apple.com/documentation/avfoundation/avplayeritemaccesslogevent?language=objc
                let errorEvent : AVPlayerItemErrorLogEvent? = log!.events[log!.events.count - 1]
                
                
                let request_start = Int(Date().timeIntervalSince1970)
                let request_response_start = Int(Date().timeIntervalSince1970)
                let request_response_end = Int(Date().timeIntervalSince1970)
                let requestError = errorEvent!.errorDomain;
                let request_type = "event_requestfailed";
                let requestUrl = (errorEvent?.uri)!;
                let requestHostName = getHostName(videoUrl: requestUrl)
                let requestErrorCode = errorEvent!.errorStatusCode
                guard let requestErrorText = errorEvent?.errorComment else { return };
              
                
                
                callNetworkAPI(requestStart:request_start , requestrResponseStart: request_response_start, requestResponseEnd: request_response_end, requestType: request_type, requestHostName: requestHostName, requestBytesLoaded: 0, requestResponseHeaders: "", requestMediaDuration_millis: 0, errorCode: requestErrorCode, error: requestError, errorText: requestErrorText)
            }
        }
    }
    
    
    
    
    // Handle notification.
    @objc func handleAVPlayerAccess(notification: Notification) {
        
        
        
        guard let playerItem = notification.object as? AVPlayerItem,
              let lastEvent = playerItem.accessLog()?.events.last else {
            return
        }
        if indicatedBitrate != Float(lastEvent.indicatedAverageBitrate){
            
            
            indicatedBitrate = Float(lastEvent.indicatedAverageBitrate)
            print("indicatedBitrate:--\(indicatedBitrate)")

        }
       
        let isNotificationRelevant :Bool = checkIfNotificationIsRelevant(notif: notification as NSNotification)
       
        if (isNotificationRelevant) {
            
         
            let playerItem = notification.object as? AVPlayerItem
            let accessLog = playerItem!.accessLog() //accessLog];
          
            calculateBandwidthMetricFromAccessLog(log:accessLog!)
            
            
        }
        
        _lastTransferEventCount = 0
        _lastTransferDuration = 0
        _lastTransferredBytes = 0
        // Use bitrate to determine bandwidth decrease or increase.
        
    }
    
    
    func checkIfNotificationIsRelevant(notif:NSNotification) -> Bool{
        let notificationItem   = notif.object as! AVPlayerItem
       
        return notificationItem == currentPlayerItem
    }
    
    
    @objc func receiveAirPlayNotification(note: NSNotification)
    {
        callScreenCastStart()
        
    }
    
    
    //MARK:- call key value observer for play and pause event
    public override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?)
    {
        
        if object as AnyObject? === player {
        
            if keyPath == "status" {
                if player.status == .readyToPlay
                {
                     state = gumletTranstion.transitionState(destinationState:GumletPlayerStateMachine.GumletPlayerStateReady.rawValue)
                     if state == GumletPlayerStateMachine.GumletPlayerStateReady.rawValue
                    {
                    playerReady()
                    }
                }
                else if player.status == .failed
                {
                    //print("error")
                    state = gumletTranstion.transitionState(destinationState:GumletPlayerStateMachine.GumletPlayerStateError.rawValue)
                    if state == GumletPlayerStateMachine.GumletPlayerStateError.rawValue
                    {
                    callError()
                    }
                }
                else if player.status == .unknown
                {
                    
                    //print("unknown")
                }
            }
            
            else if keyPath == "rate"
            {
                
                if player.rate == 1.0
                {
                    state = gumletTranstion.transitionState(destinationState:GumletPlayerStateMachine.GumletPlayerStatePlay.rawValue)
                    if state == GumletPlayerStateMachine.GumletPlayerStatePlay.rawValue
                    {
                        callPlay()
                    }
                    
                }
                else if player.rate == 0.0
                {
                    state = gumletTranstion.transitionState(destinationState:GumletPlayerStateMachine.GumletPlayerStatePaused.rawValue)
                    if state == GumletPlayerStateMachine.GumletPlayerStatePaused.rawValue
                    {
                        callPause()
                    }
                    
                }
                else
                {
                    //print("error")
                }
            }
            else if keyPath == "timeControlStatus"
            {
                if player.timeControlStatus == .playing
                {
                    if isBuffer == true {
                        
                        
                        callBufferingEnd()
                        isBuffer = false
                        
                    }
                    state = gumletTranstion.transitionState(destinationState:GumletPlayerStateMachine.GumletPlayerStatePlaying.rawValue)
                    if state == GumletPlayerStateMachine.GumletPlayerStatePlaying.rawValue
                    {
                        callPlaying()
                    }
                 
                    
                    
                }
                else if player.timeControlStatus == .paused
                {
                    //print("timeControl paused")
                }
                else if player.timeControlStatus == .waitingToPlayAtSpecifiedRate
                {
                   
                    if isBuffer == false{
                        
                        state = gumletTranstion.transitionState(destinationState:GumletPlayerStateMachine.GumletPlayerStateBuffering.rawValue)
                        if state == GumletPlayerStateMachine.GumletPlayerStateBuffering.rawValue
                        {
                            callBufferingStart()
                        }
                       
                        isBuffer = true
                    }
                    
                }
            }
            
            
        }
        
    }
    
    //MARK:- init SDK
    
    public func init_SDK(propertyId:String)//(_ playerAV:AVPlayer, propertyId:String)
    {

        callIds()
      
        
        let url: URL? = (player.currentItem?.asset as? AVURLAsset)?.url
        let video_url = url!.absoluteString
        
         currentTimeEpoch = (((Date().timeIntervalSince1970) * 1000)/1000).roundToDecimal(3)
        let screenBounds = getScreenBounds()
        screenWidth = Int(Float(screenBounds.size.width))
        screenHeight = Int(Float(screenBounds.size.height))
        
        deviceOrientation = "Portrait"//rotated()
        UserDefaults.standard.setValue(deviceOrientation, forKey: "deviceOrientation")
       
        
        
        
        UserDefaults.standard.setValue(video_url, forKey: "videoUrl")
        
        
        
        
        var device_category :String = ""
        var device_is_touchscreen :Bool = true
        let operating_system_version = UIDevice.current.systemVersion
        
     
        let device_name = UIDevice.current.name
        let operating_system = UIDevice.current.systemName
        
        switch UIDevice.current.userInterfaceIdiom.rawValue
        {
        case   0:
            device_category = "Phone"
            device_is_touchscreen = true
            break
        case 1:
            device_category = "iPad"
            device_is_touchscreen = true
            break
        case 2:
            device_category = "TV"
            device_is_touchscreen = false
            break
        case 3:
            device_category = "carPlay"
            device_is_touchscreen = true
            break
        case 4:
            device_category = "Mac"
            device_is_touchscreen = false
            break
        default:
            device_category = "Unspecified"
            device_is_touchscreen = true
            break
        }
        
        let device_manufacturer = "apple"
        
        let screenScale = UIScreen.main.scale
        
        let device_display_ppi = Float(screenScale)
        //            let device_is_touchscreen = isTouchable
        meta_device_Arch = getArchitecture()
        meta_CDN = getHostName(videoUrl: video_url)
        videoSourceUrl = video_url
       
        UserDefaults.standard.setValue(propertyId, forKey: "EnvironmentKey")
//       
        let userData = GumletInsightsUserData()
        let userName = userData.userName
        let userEmail = userData.userEmail
        let userCity = userData.userCity
        let userPhone = userData.userPhone
        let userAddLineOne = userData.userAddressLine1
        let userAddLineTwo = userData.userAddressLine2
        let userState = userData.userState
        let userZipCode = userData.userZipcode
        let userCountry = userData.userCountry
        
        
        //call API
        videAnaManager.callSessionAPI(sessionId: sessionId, userId: uniqueId,  metaDeviceArch: meta_device_Arch, userName: userName, userEmail: userEmail, userCity: userCity,userPhone:userPhone,userAddLineOne:userAddLineOne,userAddLineTwo:userAddLineTwo,userState:userState,userZipCode:userZipCode,userCountry:userCountry, gumletEnvironmentKey: propertyId, version: operating_system_version, platform: operating_system, deviceCategory: device_category, deviceManufacturer: device_manufacturer, deviceName: device_name, deviceWidth:screenWidth , deviceDisplayPPI: device_display_ppi, deviceHeight: screenHeight, deviceIsTouchable: device_is_touchscreen,localCurrentTime:currentTimeEpoch,orientation: deviceOrientation, customUserId: "")
        
        
        playerInstanceId = UUID().uuidString 
     
        UserDefaults.standard.setValue(playerInstanceId, forKey: "playerInstanceId")
        callPlayerData(propertyId, self.player, videoUrl: video_url)
       
        
    }
    
    //MARK:- Player Data
    func callPlayerData(_ gumletEnvironmentKey:String,_ playerAV:AVPlayer, videoUrl:String)
   
    {
        
        callIds()
        
        playerInstanceId = UserDefaults.standard.value(forKey: "playerInstanceId") as! String
       
        
        let screenBounds = getScreenBounds()
        screenWidth = Int(screenBounds.size.width)
        screenHeight = Int(screenBounds.size.height)
        
       
        let language = NSLocale.preferredLanguages.first
        //] firstObject];
        if ((language) != nil) {
            playerLanguage  = language!
        }
        else
        {
            playerLanguage  = "English"
        }
        
        deviceOrientation = "Portrait"//rotated()
        UserDefaults.standard.setValue(deviceOrientation, forKey: "deviceOrientation")
        
        let isPreload = "true"
        
        let bundleId = Bundle.main.bundleIdentifier!
        
        
        let playerSoftware =  "AVPlayer"
        
        let PlayerSoftwareVersion = "AVKit"
        
      
      
         currentTimeEpoch = (((Date().timeIntervalSince1970) * 1000)/1000).roundToDecimal(3)
        
        let playerData = GumletInsightsCustomPlayerData()
        let pageType = playerData.gumletPageType
        let playerIntegrationVersion = playerData.GumletPlayerIntegrationVersion
        let playerName = playerData.GumletPlayerName
        
        videAnaManager.callPlayerAPI(sessionId: sessionId, userId: uniqueId, playerInstaceId: playerInstanceId, playerHeight: screenHeight, playerWidth: screenWidth, pageType: pageType, pageUrl: bundleId, playerSoftware: playerSoftware, playerLanguageCode: playerLanguage, playerName: playerName, playerIntegrationVersion: playerIntegrationVersion, playerSoftwareVersion: PlayerSoftwareVersion, playerPreload: isPreload, gumletEnvironmentKey: gumletEnvironmentKey,localCurrentTime:currentTimeEpoch,orientation: deviceOrientation,customUserId:"")
        
        
     
    }
    
    
    //MARK:  Events API
    func callEventsAPI(eventTime : Double, previousEvents:String)
    {
        callIds()
       
        playerInstanceId = UserDefaults.standard.value(forKey: "playerInstanceId") as! String
        
        
        playBackId = UserDefaults.standard.value(forKey: "playBackId") as! String
    
        let localCurrentTime = getDate()
         currentTimeEpoch = (((Date().timeIntervalSince1970) * 1000)/1000).roundToDecimal(3)
       
        print("currentTimeEpoch:-\(currentTimeEpoch)")
        

        
        UserDefaults.standard.setValue(localCurrentTime, forKey: "localCurrentTime")
        
        let playerBounds = getPlayerViewBounds()
        let viewBounds = getScreenBounds()
        
        
        player_width = Float(playerBounds.size.width)
        player_height  = Float(playerBounds.size.height)
      
        
        
        
        screenWidth = Int(viewBounds.size.width)
        screenHeight = Int(viewBounds.size.height)
        
        
        let size = getVideoResolution()
        if size != nil {
            
            videoWidth  = Float(abs(size!.width)).rounded()
            videoHeight = Float(abs(size!.height)).rounded()


            UserDefaults.standard.setValue(videoWidth, forKey: "videoWidth")
            UserDefaults.standard.setValue(videoHeight, forKey: "videoHeight")
            
        }
        else
        {
            callError()
        }
        
      
        
        
        
        
        if  ((Int(player_width) == screenWidth && Int(player_height) == screenHeight) ||
                (Int(player_width) == screenWidth && Int(player_height) == screenHeight))
        {
            isFullScreen = true
          
        }
        else
      
        {
            
          
            isFullScreen = false
           
        }
        
        
        
        deviceOrientation = rotated()
        UserDefaults.standard.setValue(deviceOrientation, forKey: "deviceOrientation")
        
        
        NotificationCenter.default.addObserver(self, selector: #selector(rotated), name: UIDevice.orientationDidChangeNotification, object: nil)
        
        
        videoSourceUrl = UserDefaults.standard.value(forKey: "video_url") as! String
        //        //print("videoSourceUrlEveNT:--\(videoSourceUrl)")
        videoSourceType = getVideoSourceType(VideoUrl:videoSourceUrl)
        
        
        
        
        meta_CDN = getHostName(videoUrl: videoSourceUrl)
        let event_current_time = eventTime
        
        
        videoTotalTime = getTotalVideoDuration()
        let gumlet_Environment_Key = UserDefaults.standard.value(forKey: "EnvironmentKey")
        
      
        
        let upscale = upScale(playerWidth: player_width, videoWidth: videoWidth)
        let downscale = downScale(playerWidth: player_width, videoWidth: videoWidth)
        
      
        if isEventsetup == true
        {
            UserDefaults.standard.setValue(localCurrentTime, forKey: "localCurrentTimePrevEvent")
            let previousEventTime = getLastEventsTime()
            
            videAnaManager.callEventAPI(eventId: eventId, sessionId: sessionId, userId:uniqueId, playbackId: playBackId, playerInstaceId: playerInstanceId, event:eventName, startPlayTimeInMS:event_current_time, videoDownScale: 0.0, videoUpscale: 0.0, bitrateMbps:indicatedBitrate, playerRemotePlayed: "true", videoSourceDomain: meta_CDN, videoTotalDuration: videoTotalTime, videoWidthPixel:videoWidth, videoHeightPixel:videoHeight, videoSourceUrl: videoSourceUrl, videoSourceHostName: meta_CDN, videoSourceType: videoSourceType, muted:player.isMuted, previousEvent: previousEvents, previousEventTime: previousEventTime, gumletEnvironmentKey: gumlet_Environment_Key as! String,localCurrentTime:currentTimeEpoch,orientation: deviceOrientation,orientation_from:prevDeviceOrientation,fullscreen:isFullScreen,quality:"NO",errorMsg:"",errorTitle:"",errorCode:0)
        }
        else if isEventsetup == false
        {
            let previousEventTime = getLastEventsTime()
            
            
            if isPlaybackStarted == false
            {
                
                if isQualitychange == true
                
                {
                    
                    
                    if isOrientationChange == true || isOrientationChange == false{
                        
                        videAnaManager.callEventAPI(eventId: eventId, sessionId: sessionId, userId:uniqueId, playbackId: playBackId, playerInstaceId: playerInstanceId, event:eventName, startPlayTimeInMS:event_current_time, videoDownScale: downscale, videoUpscale: upscale, bitrateMbps:indicatedBitrate, playerRemotePlayed: "true", videoSourceDomain: meta_CDN, videoTotalDuration: videoTotalTime, videoWidthPixel:videoWidth, videoHeightPixel:videoHeight, videoSourceUrl: videoSourceUrl, videoSourceHostName: meta_CDN, videoSourceType: videoSourceType, muted: player.isMuted, previousEvent: previousEvents, previousEventTime: previousEventTime, gumletEnvironmentKey: gumlet_Environment_Key as! String,localCurrentTime:currentTimeEpoch,orientation: deviceOrientation,orientation_from:prevDeviceOrientation,fullscreen:isFullScreen,quality:"true",errorMsg: errorMessage,errorTitle:errorTitle,errorCode:errorCode)
                    }
                    else{
                        videAnaManager.callEventAPI(eventId: eventId, sessionId: sessionId, userId:uniqueId, playbackId: playBackId, playerInstaceId: playerInstanceId, event:eventName, startPlayTimeInMS:event_current_time, videoDownScale: downscale, videoUpscale: upscale, bitrateMbps:indicatedBitrate, playerRemotePlayed: "true", videoSourceDomain: meta_CDN, videoTotalDuration: videoTotalTime, videoWidthPixel:videoWidth, videoHeightPixel:videoHeight, videoSourceUrl: videoSourceUrl, videoSourceHostName: meta_CDN, videoSourceType: videoSourceType, muted: player.isMuted, previousEvent: previousEvents, previousEventTime: previousEventTime, gumletEnvironmentKey: gumlet_Environment_Key as! String,localCurrentTime:currentTimeEpoch,orientation: deviceOrientation,orientation_from:"",fullscreen:isFullScreen,quality:"true",errorMsg: errorMessage,errorTitle:errorTitle,errorCode:errorCode)
                    }
                }
                else if isQualitychange == false
                {
                    videAnaManager.callEventAPI(eventId: eventId, sessionId: sessionId, userId:uniqueId, playbackId: playBackId, playerInstaceId: playerInstanceId, event:eventName, startPlayTimeInMS:event_current_time, videoDownScale: downscale, videoUpscale: upscale, bitrateMbps:indicatedBitrate, playerRemotePlayed: "true", videoSourceDomain: meta_CDN, videoTotalDuration: videoTotalTime, videoWidthPixel:videoWidth, videoHeightPixel:videoHeight, videoSourceUrl: videoSourceUrl, videoSourceHostName: meta_CDN, videoSourceType: videoSourceType, muted: player.isMuted, previousEvent: previousEvents, previousEventTime: previousEventTime, gumletEnvironmentKey: gumlet_Environment_Key as! String,localCurrentTime:currentTimeEpoch,orientation: deviceOrientation,orientation_from:prevDeviceOrientation,fullscreen:isFullScreen,quality:"false",errorMsg: errorMessage,errorTitle:errorTitle,errorCode:errorCode)
                }
            }
            
            else if isPlaybackStarted == true
            {
                //need to add quality change flag , but put flag after sometime
                videAnaManager.callEventAPI(eventId: eventId, sessionId: sessionId, userId:uniqueId, playbackId: playBackId, playerInstaceId: playerInstanceId, event:eventName, startPlayTimeInMS:event_current_time, videoDownScale: 0.0, videoUpscale: 0.0, bitrateMbps:indicatedBitrate, playerRemotePlayed: "true", videoSourceDomain: meta_CDN, videoTotalDuration: videoTotalTime, videoWidthPixel:videoWidth, videoHeightPixel:videoHeight, videoSourceUrl: videoSourceUrl, videoSourceHostName: meta_CDN, videoSourceType: videoSourceType, muted: player.isMuted, previousEvent: previousEvents, previousEventTime: previousEventTime, gumletEnvironmentKey: gumlet_Environment_Key as! String,localCurrentTime:currentTimeEpoch,orientation: deviceOrientation,orientation_from:"",fullscreen:isFullScreen,quality:"NO",errorMsg:errorMessage,errorTitle:errorTitle,errorCode:errorCode)
            }
            
        }
        
    }
    
    //MARK:- seek event API
    func callSeekEventsAPI(eventTime : Double, previousEvents:String, seekingTime:Double,seekedTime:Double)
    {
        callIds()
       
        playerInstanceId = UserDefaults.standard.value(forKey: "playerInstanceId") as! String
        
        playBackId = UserDefaults.standard.value(forKey: "playBackId") as! String
        
        let localCurrentTime = getDate()
        currentTimeEpoch = (((Date().timeIntervalSince1970) * 1000)/1000).roundToDecimal(3)
        
        UserDefaults.standard.setValue(localCurrentTime, forKey: "localCurrentTime")
        
        let playerBounds = getPlayerViewBounds()
        let viewBounds = getScreenBounds()
        
        
        player_width = Float(playerBounds.size.width)
        player_height  = Float(playerBounds.size.height)
       
        
        
        screenWidth = Int(Float(viewBounds.size.width))
        screenHeight = Int(Float(viewBounds.size.height))
        
        let size = getVideoResolution()
        if size != nil {
            
            videoWidth  = Float(abs(size!.width)).rounded()
            videoHeight = Float(abs(size!.height)).rounded()
        }
        else
        {
            callError()
        }
        
        
        
        if  ((Int(player_width) == screenWidth && Int(player_height) == screenHeight) ||
                (Int(player_width) == screenHeight && Int(player_height) == screenWidth))
        {
           
            isFullScreen = true
           
        }
        else
       
        {
            
           
            isFullScreen = false
           
        }
        
        
        
        
        NotificationCenter.default.addObserver(self, selector: #selector(rotated), name: UIDevice.orientationDidChangeNotification, object: nil)
        
        
        videoSourceUrl = UserDefaults.standard.value(forKey: "video_url") as! String
        videoSourceType = getVideoSourceType(VideoUrl:videoSourceUrl)
        let event_current_time = eventTime
        
        
        videoTotalTime = getTotalVideoDuration()
        let gumlet_Environment_Key = UserDefaults.standard.value(forKey: "EnvironmentKey")
        
      
        
        let upscale = upScale(playerWidth: player_width, videoWidth: videoWidth)
        let downscale = downScale(playerWidth: player_width, videoWidth: videoWidth)
        
        
        UserDefaults.standard.setValue(localCurrentTime, forKey: "localCurrentTimePrevEvent")
      
        let previousEventTime = getLastEventsTime()
        
        if isOrientationChange == true || isOrientationChange == false
        {
            
            videAnaManager.callSeekEventAPI(eventId: eventId, sessionId: sessionId, userId:uniqueId, playbackId: playBackId, playerInstaceId: playerInstanceId, event:eventName,seekingtime: seekingTime, seekedTime: seekedTime, startPlayTimeInMS:event_current_time, videoDownScale: downscale, videoUpscale: upscale, bitrateMbps:indicatedBitrate, playerRemotePlayed: "true", videoSourceDomain: meta_CDN, videoTotalDuration: videoTotalTime, videoWidthPixel:videoWidth, videoHeightPixel:videoHeight, videoSourceUrl: videoSourceUrl, videoSourceHostName: meta_CDN, videoSourceType: videoSourceType, muted: player.isMuted, previousEvent: previousEvents, previousEventTime: previousEventTime, gumletEnvironmentKey: gumlet_Environment_Key as! String,localCurrentTime:currentTimeEpoch,orientation: deviceOrientation,orientation_from:prevDeviceOrientation,fullscreen:isFullScreen,quality:"NO")
        }
        else{
            videAnaManager.callSeekEventAPI(eventId: eventId, sessionId: sessionId, userId:uniqueId, playbackId: playBackId, playerInstaceId: playerInstanceId, event:eventName,seekingtime: seekingTime, seekedTime: seekedTime, startPlayTimeInMS:event_current_time, videoDownScale: downscale, videoUpscale: upscale, bitrateMbps:Float(indicatedBitrate), playerRemotePlayed: "true", videoSourceDomain: meta_CDN, videoTotalDuration: videoTotalTime, videoWidthPixel:videoWidth, videoHeightPixel:videoHeight, videoSourceUrl: videoSourceUrl, videoSourceHostName: meta_CDN, videoSourceType: videoSourceType, muted: player.isMuted, previousEvent: previousEvents, previousEventTime: previousEventTime, gumletEnvironmentKey: gumlet_Environment_Key as! String,localCurrentTime:currentTimeEpoch,orientation: deviceOrientation,orientation_from:"",fullscreen:isFullScreen,quality:"NO")
        }
    }
    
    
    
    //MARK:- Network API
    func callNetworkAPI(requestStart:Int, requestrResponseStart: Int, requestResponseEnd: Int, requestType: String, requestHostName: String, requestBytesLoaded: Int64, requestResponseHeaders: String, requestMediaDuration_millis: Int,  errorCode: Int, error: String, errorText: String)
    {
        
        callIds()
        
        let size = getVideoResolution()
        if size != nil {
            
            videoWidth  = Float(abs(size!.width)).rounded()
            videoHeight = Float(abs(size!.height)).rounded()
        }
        else
        {
            callError()
        }
        
       
         currentTimeEpoch = (Date().timeIntervalSince1970 * 1000).roundToDecimal(3)
        
        let gumlet_Environment_Key = UserDefaults.standard.value(forKey: "EnvironmentKey")
        
        videAnaManager.callNetworkRequestAPI(request_id:networkRequestId, session_id:sessionId, user_id: uniqueId, source_id:gumlet_Environment_Key as! String, player_instance_id: playerInstanceId, request_start: requestStart, request_response_start: requestrResponseStart, request_response_end: requestResponseEnd, request_type: requestType, request_hostname: requestHostName, request_bytes_loaded: requestBytesLoaded, request_response_headers: requestResponseHeaders, request_media_duration_millis: requestMediaDuration_millis, request_video_width_pixels: videoWidth, request_video_height_pixels: videoHeight, error_code: errorCode, error: error, error_text: errorText, created_at: currentTimeEpoch)
    }
    
    
    //MARK:- get play and pause time
   public func getPlay_Pause_Time() -> Double
    {
        let currentTime = player.currentTime()
        let time = CMTimeGetSeconds(currentTime)
      
        let playTimeInMS = (time * 1000.0).roundToDecimal(2)
        
        
        return playTimeInMS
    }
    
    //MARK:- Device Data
    private func getArchitecture() -> String {
        let info = NXGetLocalArchInfo()
        let device_Arch =  NSString(utf8String: (info?.pointee.name)!)
        return device_Arch! as String
    }
    
    //MARK:-- get video file Extension
    
    func getVideoSourceType(VideoUrl:String)->String
    {
        let filename: NSString = VideoUrl as NSString
        let pathExtention = filename.pathExtension
        return pathExtention
    }
    
    //MARK:--- get host name
    func getHostName(videoUrl:String) -> String
    {
        var domain :String = ""
        if  let url = URL(string: videoUrl)
        {
            domain = url.host!
           
        }
        return domain
    }
    
    //MARK:- calculate previous event time
    func getLastEventsTime()-> Float
    {
        var prevTime : Int = 0
        
        let prevEventTime = UserDefaults.standard.value(forKey: "localCurrentTimePrevEvent")as! String
        //        //print("prevEventTime:-\(prevEventTime)")
        
        if prevEventTime == "0"
        {
            //print("prevEventTime:--nulll")
        }
        else
        {
                 
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS"//this your string date format
            dateFormatter.timeZone = NSTimeZone(name: "UTC") as TimeZone?
            let dated = dateFormatter.date(from: prevEventTime )
           
                       
            prevTime = Int(dated!.timeIntervalSince1970 * 1000)
                        print("prevTime:--\(prevTime)")
        }
       
        let localCurrentTimeEvent = UserDefaults.standard.value(forKey: "localCurrentTime")as! String
 
        let dFormatter = DateFormatter()
        dFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS"//this your string date format
        dFormatter.timeZone = NSTimeZone(name: "UTC") as TimeZone?
        let dated1 = dFormatter.date(from: localCurrentTimeEvent)//getLocalCurrentTime()
        //        //print("dated1:-\(String(describing: dated1))")
        let lTime = Int(dated1!.timeIntervalSince1970 * 1000)
               print("ltime:-\(lTime)")
        let diff = lTime - prevTime
               print("diff:-\(diff)")
        
        UserDefaults.standard.setValue(localCurrentTimeEvent, forKey: "localCurrentTimePrevEvent")
        
        return Float(diff)
    }
    
    
    //MARK:- get total video duration
    func getTotalVideoDuration() -> Double
    {
        let seconds = (player.currentItem?.asset.duration)!
        let  video_total_time = CMTimeGetSeconds(seconds)
        let videoTotalDuration = video_total_time * 1000
        
       
        return videoTotalDuration
    }
    
    func getVideoCover()
    {
        let videoURL = NSURL(string:videoSourceUrl)
        let avAsset = AVAsset(url:videoURL! as URL)
        let imageGenerator = AVAssetImageGenerator(asset: avAsset)
        let durationSeconds = CMTimeGetSeconds(avAsset.duration)
        let time = CMTime(seconds: durationSeconds/3.0, preferredTimescale: 600)
        let times = [NSValue(time: time)]
        imageGenerator.generateCGImagesAsynchronously(forTimes: times, completionHandler: {
            requestedTime, image, actualTime, result, error in
            guard let cgImage = image else
            {
                //print("No image!")
                return
            }
            let uiImage = UIImage(cgImage: cgImage)
            UIImageWriteToSavedPhotosAlbum(uiImage, nil, nil, nil);
        })
    }
    
    
    //MARK:-- video size
  public func getVideoResolution() -> CGSize? {
        
       
       
        let size = (self.player.currentItem?.presentationSize)
           return size
        
    }
    
   public func getScreenBounds() -> CGRect
    {
        return UIScreen.main.bounds
    }
    
    func getPlayerViewBounds() -> CGRect
    {
        return controller.view.bounds
    }
    
    
    func getLocalCurrentTime()->Int {
        
        return Int(Date().timeIntervalSince1970 * 1000)
    }
    
    @objc func rotated() -> String
    {
        
        if UIScreen.main.bounds.width < UIScreen.main.bounds.height
        {
          
            deviceOrientation = "Portrait"
           
            
            if(isOrientationChange == true)
            {
                prevDeviceOrientation = "Landscape"
                callDeviceOrientation()
                
            }
            
        }
        else if UIScreen.main.bounds.width > UIScreen.main.bounds.height
        {
           
            deviceOrientation = "Landscape"
           
            
            if (isOrientationChange == false)
            {
                prevDeviceOrientation = "Portrait"
                callDeviceOrientation()
                
            }
            
            
        }
        
        
        return deviceOrientation
        
    }
    
    //MARK:-- get Upscale
  public func upScale(playerWidth:Float,videoWidth:Float) -> Float
    {
        //playerwidth high and videoWidth less , means expand video width as per player width
        var upScale : Float = 0.0
       
        if (playerWidth > videoWidth)
        {
            upScale = (abs((playerWidth - videoWidth)/videoWidth)*100)//.roundToDecimalFloat(2)
            
        }
        else{
            upScale = 0.0
        }
        return upScale
    }
    
    //MARK:-- get downScale
    public func downScale(playerWidth:Float,videoWidth:Float) -> Float
    {
        //playerwidth less and videoWidth high , means  compress video width as per player width
        
        var downScale : Float = 0.0
        if (playerWidth < videoWidth)
        {
            downScale = (abs((playerWidth - videoWidth)/videoWidth)*100)//.roundToDecimalFloat(2)
           
        }
        else{
            downScale = 0.0
        }
        return downScale
    }
    
    
    func getDate() -> String
    {
        
        let date = Date()
        let df = DateFormatter()
        df.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS"
        df.timeZone = NSTimeZone(name: "UTC") as TimeZone?
        
        let dateString = df.string(from: date)

        
        return dateString
    }
    
   
    public func currentEpochTime() -> Double
    {
        return (((Date().timeIntervalSince1970) * 1000)/1000).roundToDecimal(3)
    }
    
    func getCurrentPlayheadTimeMs() -> Double {
        return CMTimeGetSeconds(player.currentTime()) * 1000;
    }
    
    //set the timer, which will update your progress bar. You can use whatever time interval you want
    
    func calculateBandwidthMetricFromAccessLog(log:AVPlayerItemAccessLog)
    {
        if isplaybackFinish == false{
            if log != nil && log.events.count > 0
            {
                // https://developer.apple.com/documentation/avfoundation/avplayeritemaccesslogevent?language=objc
                let event : AVPlayerItemAccessLogEvent? = log.events[log.events.count - 1]
                
            
                
                if (_lastTransferEventCount != log.events.count) {
                    _lastTransferDuration = 0
                    _lastTransferredBytes = 0
                    _lastTransferEventCount = Int8(log.events.count);
                }
                
                
                
               
                let request_start = Int(Date().timeIntervalSince1970)//getDate()//(requestStartSecs * 1000)
               
                let request_response_start = Int(Date().timeIntervalSince1970)
               
                let request_response_end  = Int(Date().timeIntervalSince1970)//(requestCompletedTime * 1000)
               
                let request_bytes_loaded :Int64 =  Int64(event!.numberOfBytesTransferred) - (_lastTransferredBytes)
               
                
                let request_type = "event_requestcompleted"
                let request_response_headers = "";
                var requestHostName :String? = ""
                
                if event?.uri != nil
                {
                    requestHostName =  getHostName(videoUrl:(event?.uri)!)
                   
                }
                else{
                    
                    requestHostName = ""
                }
                
                
             
                let requestMediaDuration :Int = Int(event!.segmentsDownloadedDuration)
              
                _lastTransferredBytes = Int64(event!.numberOfBytesTransferred);
                _lastTransferDuration = event!.transferDuration;
                
                
                callNetworkAPI(requestStart: request_start, requestrResponseStart: request_response_start, requestResponseEnd: request_response_end, requestType: request_type, requestHostName: requestHostName!, requestBytesLoaded: request_bytes_loaded, requestResponseHeaders: request_response_headers, requestMediaDuration_millis: requestMediaDuration, errorCode: 200, error: "", errorText: "Success")
            }
        }
        else if isplaybackFinish == true{
            
            if log != nil && log.events.count > 0
            {
                // https://developer.apple.com/documentation/avfoundation/avplayeritemaccesslogevent?language=objc
                let event : AVPlayerItemAccessLogEvent? = log.events[log.events.count - 1]
                
                if (_lastTransferEventCount != log.events.count) {
                    _lastTransferDuration = 0
                    _lastTransferredBytes = 0
                    _lastTransferEventCount = Int8(log.events.count);
                }
                
                
                //            //print("------------------------------- requestResponseStart/requestResponseEnd/requestBytesLoaded to compute, the value are very close.
                
                
                
                
                let request_start = Int(Date().timeIntervalSince1970)//getDate()
                
                let request_response_start = Int(Date().timeIntervalSince1970)//getDate()
                
                let request_response_end  = Int(Date().timeIntervalSince1970)
                
                let request_bytes_loaded :Int64 =  Int64(event!.numberOfBytesTransferred) - (_lastTransferredBytes)
                
                
                let request_type = "event_requestcanceled"
                let request_response_headers = "";
                var requestHostName :String? = ""
                
                if requestHostName != nil{
                    
                    requestHostName =  getHostName(videoUrl:(event?.uri)!)
                    //                //print("requestHostName:\(requestHostName)")
                }
                else{
                    
                    requestHostName = ""
                }
                
                let requestMediaDuration :Int = Int(event!.segmentsDownloadedDuration)
               
                
                _lastTransferredBytes = Int64(event!.numberOfBytesTransferred);
                _lastTransferDuration = event!.transferDuration;
                
                
                callNetworkAPI(requestStart: request_start, requestrResponseStart: request_response_start, requestResponseEnd: request_response_end, requestType: request_type, requestHostName: requestHostName!, requestBytesLoaded: request_bytes_loaded, requestResponseHeaders: request_response_headers, requestMediaDuration_millis: requestMediaDuration, errorCode: 200, error: "", errorText: "Success")
            }
            
            
        }
        
    }
    
    
    
    

    
    func checkVideoQualityChange()
    {
        let videoH  = UserDefaults.standard.value(forKey: "videoHeight") as! Float
        let videoW = UserDefaults.standard.value(forKey: "videoWidth") as! Float
        let size = getVideoResolution()
        if videoW  != Float(abs(size!.width)).rounded() && videoH != Float(abs(size!.height)).rounded()
        {
           

            if (isVideoQualityChange == false)
            {

                callVideoQualityChange()
            }
            
        }
        else
        {
           

            if isVideoQualityChange == true
            {
               
                isVideoQualityChange = false
            }
        }
    }
    
    
    func checkMuteAnUnmute()
    {
        if videoMuted == false {
            
            if player.isMuted == true
            {
                print("mute")
                callMute()
                videoMuted = true
            }
        }
        else if player.isMuted == false
        {
            if videoUnMuted == true
            {
                print("no mute")
                callUnmute()
                videoUnMuted = false
            }
            
        }
    }
    
    func checkForSeekEvent(){
        
//                print("seek check")
        let playheadTimeElapsed :Double = (getCurrentPlayheadTimeMs() - Double(lastUpdateTime)) / 1000;
       
        
        let wallTimeElapsed : Double = CFAbsoluteTimeGetCurrent() - Double(timeOfUpdate)
       
        
        let drift = playheadTimeElapsed - wallTimeElapsed;
    
        
        if fabsf(Float(playheadTimeElapsed)) > 0.5 &&
            fabsf(Float(drift)) > 0.2 &&
            (state == GumletPlayerStateMachine.GumletPlayerStatePaused.rawValue || state == GumletPlayerStateMachine.GumletPlayerStatePlay.rawValue) {
            if isSeeking == false{
                isSeeking = true
                print("seeking start")
                let play_current_time = getPlay_Pause_Time()
                //print("play_current_time\(play_current_time)")
                UserDefaults.standard.setValue(play_current_time, forKey: "seekVideoStartTime")
                let seekStartTimestamp = getDate()
                UserDefaults.standard.setValue(seekStartTimestamp, forKey: "seekStartTimestamp")
            }
        }
        else{
            if isSeeking == true{
                isSeeking = false
                
            }
        }
    }
    
    func updateLastPlayheadTime() {
        lastUpdateTime = Float(getCurrentPlayheadTimeMs())
        timeOfUpdate = CFAbsoluteTimeGetCurrent()
    }
    
   public func getEventType(eventName :Int) -> String
    {
        switch(eventName)
        {
        case 0:
            return "event_player_setup"
        case 1:
            return "event_player_ready"
        case 2:
            return "event_play"
        case 3:
            return "event_playing"
        case 4:
            return "event_rebuffer_start"
        case 5:
            return "event_rebuffer_end"
        case 6:
            return "event_paused"
        case 7:
            return "event_end"
        case 8:
            return "event_video_change"
        case 9:
            return "event_device_orientation_changed"
        case 10:
            return "event_quality_change"
        default:
            return "no event"
        }
    }
    
    public func getPreviousEventName(prevEventName:Int) -> String
    {
        switch (prevEventName)
        {
        case 0:
            return ""
        case 1:
            return "event_player_setup"
        case 2:
            return "event_player_ready"
        case 3:
            return "event_play"
        case 4:
            return "event_playing"
        case 5:
            return "event_rebuffer_start"
        case 6:
            return "event_rebuffer_end"
        case 7:
            return "event_paused"
        default:
            return "no event"
            
        }
        
    }
    
    
    deinit {
        
        //print("deinint")
        UserDefaults.standard.removeObject(forKey: "video_url")
        
        UserDefaults.standard.removeObject(forKey: "playBackId")
        UserDefaults.standard.removeObject(forKey: "playerInstanceId")
        
    }
}

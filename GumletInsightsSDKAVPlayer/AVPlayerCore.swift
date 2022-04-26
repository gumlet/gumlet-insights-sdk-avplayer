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
    var playerLanguage : String = ""
    var deviceOrientation :String = ""
    var playerName:String = ""
    var prevDeviceOrientation : String = ""
    var currentState : String = ""
    var timeObservation: Any!
    var localCurrentTime : Int = 0
    var indicatedBitrate:Float = 0.0
    var videoWidth : Float = 0.0
    var videoHeight :Float = 0.0
    var player_width:Float = 0.0
    var player_height:Float = 0.0
    var screenWidth:Int = 0
    var screenHeight:Int = 0
    var play_current_time:Double = 0.0
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
    var state : Bool = false
    var videoMuted :Bool = false
    var videoUnMuted : Bool = false
    var isFullScreen :Bool = false
    public var isPlaybackStarted :Bool = true
    var isplaybackFinish :Bool = false
    var errorTitle:String = ""
    var errorMessage:String = ""
    var errorCode = 0
    // init Gumlet Video Manager
    var videAnaManager = GumletInsightsManager()
    var gumletTranstion = GumletTransition()
    // init player
    var player = AVPlayer()
    let controller = AVPlayerViewController()
    var currentPlayerItem: AVPlayerItem?
    var timer : Timer?

    
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
        UserDefaults.standard.setValue(session_Id, forKey: "user_session")
        UserDefaults.standard.set(Date(), forKey:"user_session_creation_time")
        UserDefaults.standard.set("", forKey: "backgroundCurrentTime")
        UserDefaults.standard.set("",  forKey:"foregroundCurrentTime")
        return session_Id
    }
    
   public func checkSessionId() -> String
    {
            if let session_id = UserDefaults.standard.string(forKey: "user_session") {
           
            if let date = UserDefaults.standard.object(forKey: "user_session_creation_time")as? Date {
                let backgroundCurrentTime = UserDefaults.standard.object(forKey: "backgroundCurrentTime")as? Date
                let foregroundCurrentTime = UserDefaults.standard.object(forKey: "foregroundCurrentTime")as? Date
                if backgroundCurrentTime == nil && foregroundCurrentTime == nil{
                  if let diff = Calendar.current.dateComponents([.minute], from: date, to: Date()).minute, diff > 30
                    {
                        return createSessionId()
                    }
                }else if foregroundCurrentTime == nil
                {
                    
                }
                else if backgroundCurrentTime == nil
                {
                   
                }
                else
                {
                    let diff = Calendar.current.dateComponents([.minute], from: backgroundCurrentTime!, to: foregroundCurrentTime!).minute
                    if  diff! > 30
                    {
                       return createSessionId()
                    }
                    else{
                        if diff! > 30 + diff!
                        {
                           
                        }
                    }
                }
            }
            return session_id
        }
        else{
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
    public func setupPlayer(playerAV:AVPlayer, propertyId:String,userData:GumletInsightsUserData,customerPlayerData:GumletInsightsCustomPlayerData)
    {
        self.player = playerAV
        currentPlayerItem = player.currentItem
        init_SDK(propertyId: propertyId,customUserData:userData,customerPlayerData:customerPlayerData)
        let video_url: URL? = (player.currentItem?.asset as? AVURLAsset)?.url
        callEventSetUp(videoURL: video_url!.absoluteString)
        self.player.addObserver(self, forKeyPath: "status", options: [.old, .new], context: nil)
        self.player.addObserver(self, forKeyPath: "rate", options: [.old, .new], context: nil)
        self.player.addObserver(self, forKeyPath: "timeControlStatus", options: [.old, .new], context: nil)
        NotificationCenter.default.addObserver(self, selector:#selector(self.playerDidFinishPlaying),name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: player.currentItem)
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
            isVideoChange = true
        }
        UserDefaults.standard.setValue(videoURL, forKey: "video_url")
       
        isPlaybackStarted = true
        isEventsetup = true
        eventName = Events.isPlayerSetup.rawValue
        currentState = GumletPlayerStateMachine.GumletPlayerStateViewinit.rawValue
        UserDefaults.standard.setValue(currentState, forKey: "currentState")
        let state = gumletTranstion.transitionState(eventName: eventName, currentState: currentState, destinationState: GumletPlayerStateMachine.GumletPlayerStateViewinit.rawValue)
        if state == true
     {
        let prevEvents = ""
        UserDefaults.standard.setValue(eventName, forKey: "eventName")
        play_current_time = getPlay_Pause_Time()
        callEventsAPI(eventTime: play_current_time, previousEvents:prevEvents, eventName: eventName)
     }
        if isVideoChange == true{
            callVideoChange()
        }
    }
    
    public func playerReady()
    {
        isEventsetup = false
        eventName = Events.isPlayerReady.rawValue
        let state = gumletTranstion.transitionState(eventName: eventName, currentState: currentState, destinationState: GumletPlayerStateMachine.GumletPlayerStateReady.rawValue)
        if state == true
        {
            let prevEvents = UserDefaults.standard.value(forKey: "eventName") as! String
            UserDefaults.standard.setValue(eventName, forKey: "eventName")
            play_current_time = getPlay_Pause_Time()
            callEventsAPI(eventTime: play_current_time, previousEvents:prevEvents, eventName: eventName)
        }
        currentState = GumletPlayerStateMachine.GumletPlayerStateReady.rawValue
        UserDefaults.standard.setValue(currentState, forKey: "currentState")
        DispatchQueue.main.async {
            let interval = CMTimeMakeWithSeconds(0.1, preferredTimescale:Int32(NSEC_PER_MSEC))// CMTime(seconds: 1, preferredTimescale: 10)
            self.timeObservation = self.player.addPeriodicTimeObserver(forInterval: interval, queue: .main, using: {
                [weak self] time in
                guard let weakSelf = self else {
                    return }
                let seconds = CMTimeGetSeconds(time)
                weakSelf.checkForSeekEvent()
                weakSelf.checkVideoQualityChange()
                weakSelf.checkMuteAnUnmute()
                weakSelf.updateLastPlayheadTime()
            })
        }
    }
    
    public func callPlaying(currentState:String, playCurrentTime:Double)
    {
        callSeekEvent()
        eventName = Events.isPlaying.rawValue
        let state = gumletTranstion.transitionState(eventName: eventName, currentState: currentState, destinationState: GumletPlayerStateMachine.GumletPlayerStatePlaying.rawValue)
        if state == true
        {
            let prevEvents = UserDefaults.standard.value(forKey: "eventName") as! String
            UserDefaults.standard.setValue(eventName, forKey: "eventName")
            callEventsAPI(eventTime: playCurrentTime, previousEvents:prevEvents, eventName:    eventName)
            }
            self.currentState = GumletPlayerStateMachine.GumletPlayerStatePlaying.rawValue
            if isPlaybackStarted == true
            {
                callPlaybackStarted()
                isPlaybackStarted = false
            }
            updatePlaybackEvent()
        }
    
    func callPlaybackStarted()
    {
        eventName = Events.isPlaybackStarted.rawValue
        let prevEvents = UserDefaults.standard.value(forKey: "eventName") as! String
        UserDefaults.standard.setValue(eventName, forKey: "eventName")
        callEventsAPI(eventTime: 0.0, previousEvents:prevEvents, eventName: eventName)
        currentState = GumletPlayerStateMachine.GumletPlayerStatePlaying.rawValue
    }
//    MARK:-- update playback Event Timer
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
        callEventsAPI(eventTime: play_current_time, previousEvents:prevEvents, eventName: eventName)
        currentState = GumletPlayerStateMachine.GumletPlayerStatePlaying.rawValue
    }
    
    func callSeekEvent()
    {
        if isSeeking == true
        {
            callSeekedEvent()
            isSeeking = false
        }
    }
    
    public func callVideoChange()
    {
        timer?.invalidate()
        isVideoChange = false
        eventName = Events.isVideochange.rawValue
        let state = gumletTranstion.transitionState(eventName: eventName, currentState: currentState, destinationState: currentState)
        if state == true
        {
        var prevEvents :String? = ""
        if prevEvents != nil{
            prevEvents = (UserDefaults.standard.value(forKey: "eventName") as! String)
        }
        else{
            prevEvents = ""
        }
        UserDefaults.standard.setValue(eventName, forKey: "eventName")
        play_current_time = getPlay_Pause_Time()
        callEventsAPI(eventTime: play_current_time, previousEvents:prevEvents!, eventName: eventName)
        }
    }
    
    func callVideoQualityChange()
    {
        isQualitychange = true
        isVideoQualityChange = true
        eventName = Events.isQualityChange.rawValue
        let state = gumletTranstion.transitionState(eventName: eventName, currentState: currentState, destinationState: currentState)
        if state == true
        {
            let prevEvents = UserDefaults.standard.value(forKey: "eventName") as! String
            UserDefaults.standard.setValue(eventName, forKey: "eventName")
            play_current_time = getPlay_Pause_Time()
            callEventsAPI(eventTime: play_current_time, previousEvents:prevEvents, eventName: eventName)
        }
    }
    
    public func callSeekedEvent()
    {
        eventName = Events.isSeek.rawValue
        var prevEvents :String? = ""
        let seekTime = getDate()
        UserDefaults.standard.setValue(seekTime, forKey: "seekTimeEnd")
        if prevEvents != nil
        {
            prevEvents = (UserDefaults.standard.value(forKey: "eventName") as! String)
        }
        else
        {
            prevEvents = ""
        }
        UserDefaults.standard.setValue(eventName, forKey: "eventName")
        let seekStartTime = UserDefaults.standard.value(forKey: "seekVideoStartTime")
        let t1 = Float(self.player.currentTime().value)
        let t2 = Float(self.player.currentTime().timescale)
        let currentTime = t1 / t2
        play_current_time = getPlay_Pause_Time()
        let seekedTime = play_current_time
        callSeekEventsAPI(eventTime: play_current_time, previousEvents: prevEvents!, seekingTime: seekStartTime as! Double, seekedTime:seekedTime)
    }
    
    func callError()
    {
        if (player.error != nil)
        {
            let errCode = player.error! as NSError
            errorCode = errCode.code
            errorTitle = errCode.domain
            errorMessage = errCode.localizedDescription
        }
        else if ((currentPlayerItem != nil) && (currentPlayerItem?.error != nil))
        {
            let errCode = (currentPlayerItem?.error)! as NSError
            errorMessage = errCode.localizedDescription
            errorCode = errCode.code
            errorTitle = errCode.domain
        }
        eventName = Events.isEventError.rawValue
        let state = gumletTranstion.transitionState(eventName: eventName, currentState: currentState, destinationState: GumletPlayerStateMachine.GumletPlayerStateError.rawValue)
        if state == true
        {
            var prevEvents :String? = ""
            if prevEvents != nil
            {
            
                prevEvents = (UserDefaults.standard.value(forKey: "eventName") as! String)
            }
        else
            {
            
                prevEvents = ""
            }
        UserDefaults.standard.setValue(eventName, forKey: "eventName")
        isBuffer = true
        play_current_time = getPlay_Pause_Time()//Double(currentTime)
        callEventsAPI(eventTime: play_current_time, previousEvents:prevEvents!, eventName: eventName)
        }
        currentState = GumletPlayerStateMachine.GumletPlayerStateError.rawValue
        UserDefaults.standard.setValue(currentState, forKey: "currentState")
    }
    
 
    @objc func appMovedToBackground()
    {
        UserDefaults.standard.setValue(Date(), forKey: "backgroundCurrentTime")
    }

   @objc func appCameToForeground()
   {
      UserDefaults.standard.setValue(Date(), forKey: "foregroundCurrentTime")
   }
    
    
    @objc func playerDidFinishPlaying()
    {
        isplaybackFinish = true
        timer?.invalidate()
        timer = nil
        eventName = Events.isEnd.rawValue
        let state = gumletTranstion.transitionState(eventName: eventName, currentState: currentState, destinationState: GumletPlayerStateMachine.GumletPlayerStateViewEnd.rawValue)
        if state == true
        {
            let prevEvents = UserDefaults.standard.value(forKey: "eventName") as! String
            UserDefaults.standard.setValue(eventName, forKey: "eventName")
            play_current_time = getPlay_Pause_Time()
            callEventsAPI(eventTime: play_current_time, previousEvents:prevEvents, eventName: eventName)
        }
        currentState = GumletPlayerStateMachine.GumletPlayerStateViewEnd.rawValue
        UserDefaults.standard.setValue(currentState, forKey: "currentState")
    }
    
   @objc func handleAVPlayerError(notification: Notification)
   {
        let isNotificationRelevant :Bool = checkIfNotificationIsRelevant(notif: notification as NSNotification)
       if (isNotificationRelevant)
       {
            let playerItem = notification.object as? AVPlayerItem
            let log:AVPlayerItemErrorLog? = playerItem!.errorLog()
            if (log != nil && log!.events.count > 0)
            {
                //https://developer.apple.com/documentation/avfoundation/avplayeritemaccesslogevent?language=objc
                let errorEvent : AVPlayerItemErrorLogEvent? = log!.events[log!.events.count - 1]
                let request_start = Int(Date().timeIntervalSince1970)//getDate()
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
    @objc func handleAVPlayerAccess(notification: Notification)
    {
        guard let playerItem = notification.object as? AVPlayerItem,
              let lastEvent = playerItem.accessLog()?.events.last else
        {
            return
        }
        if indicatedBitrate != Float(lastEvent.indicatedAverageBitrate)
        {
            indicatedBitrate = Float(lastEvent.indicatedAverageBitrate)
        }
        let isNotificationRelevant :Bool = checkIfNotificationIsRelevant(notif: notification as NSNotification)
        if (isNotificationRelevant)
        {
            let playerItem = notification.object as? AVPlayerItem
            let accessLog = playerItem!.accessLog()
            calculateBandwidthMetricFromAccessLog(log:accessLog!)
        }
        _lastTransferEventCount = 0
        _lastTransferDuration = 0
        _lastTransferredBytes = 0
    }
    
    func checkIfNotificationIsRelevant(notif:NSNotification) -> Bool
    {
        let notificationItem   = notif.object as! AVPlayerItem
        return notificationItem == currentPlayerItem
    }
    
    
    @objc func receiveAirPlayNotification(note: NSNotification)
    {
        let eventHandler = EventHandler()
        eventHandler.playerCore = self
        play_current_time = getPlay_Pause_Time()
        eventHandler.callScreenCastStart(playCurrentTime: play_current_time)
    }
    
    
    //MARK:- call key value observer for play and pause event
    public override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?)
    {
       let eventHandler = EventHandler()
        eventHandler.playerCore = self
        
        if object as AnyObject? === player {
           if keyPath == "status" {
            if player.status == .readyToPlay
                {
                    self.playerReady()
                }
                else if player.status == .failed
                {
                    callError()
                }
                else if player.status == .unknown
                {
                    callError()
                }
            }
            else if keyPath == "rate"
            {
                if player.rate == 1.0
                {
                    let prevEvents = UserDefaults.standard.value(forKey: "eventName") as! String
                    let currentStates = UserDefaults.standard.value(forKey: "currentState") as! String
                    play_current_time = getPlay_Pause_Time()
                    eventHandler.callPlay(prevEvents: prevEvents, currentState: currentStates, playCurrentTime: play_current_time)
                   currentState = GumletPlayerStateMachine.GumletPlayerStatePlay.rawValue
                    UserDefaults.standard.setValue(currentState, forKey: "currentState")
                }
                else if player.rate == 0.0
                {
                    let currentStates = UserDefaults.standard.value(forKey: "currentState") as! String
                    play_current_time = getPlay_Pause_Time()
                    eventHandler.callPause(currentState: currentStates,playCurrentTime: play_current_time)
                    currentState = GumletPlayerStateMachine.GumletPlayerStatePaused.rawValue
                    UserDefaults.standard.setValue(currentState, forKey: "currentState")
                }
            }
            else if keyPath == "timeControlStatus"
            {
               if player.timeControlStatus == .playing
                {
                    if isBuffer == true {
                    let currentStates = UserDefaults.standard.value(forKey: "currentState") as! String
                    play_current_time = getPlay_Pause_Time()
                    eventHandler.callBufferingEnd(currentState: currentStates,playCurrentTime: play_current_time)
                    self.currentState = GumletPlayerStateMachine.GumletPlayerStateBuffering.rawValue
                    UserDefaults.standard.setValue(currentState, forKey: "currentState")
                    isBuffer = false
                    }
                    let currentStates = UserDefaults.standard.value(forKey: "currentState") as! String
                    play_current_time = getPlay_Pause_Time()
                    callPlaying(currentState: currentStates,playCurrentTime: play_current_time)
                    self.currentState = GumletPlayerStateMachine.GumletPlayerStatePlaying.rawValue
                    UserDefaults.standard.setValue(currentState, forKey: "currentState")
               }
               else if player.timeControlStatus == .paused
               {
                    
               }
               else if player.timeControlStatus == .waitingToPlayAtSpecifiedRate
               {
                    if isBuffer == false{
                    let currentStates = UserDefaults.standard.value(forKey: "currentState") as! String
                    play_current_time = getPlay_Pause_Time()
                    eventHandler.callBufferingStart(currentState: currentStates,playCurrentTime: play_current_time)
                    self.currentState = GumletPlayerStateMachine.GumletPlayerStateBuffering.rawValue
                    UserDefaults.standard.setValue(currentState, forKey: "currentState")
                    isBuffer = true
                }
               }
            }
        }
    }
    
    //MARK:- init SDK
    
    public func init_SDK(propertyId:String,customUserData:GumletInsightsUserData,customerPlayerData:GumletInsightsCustomPlayerData)//(_ playerAV:AVPlayer, propertyId:String)
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
        meta_device_Arch = getArchitecture()
        meta_CDN = getHostName(videoUrl: video_url)
        videoSourceUrl = video_url
        UserDefaults.standard.setValue(propertyId, forKey: "EnvironmentKey")
        let userData = customUserData
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
        playerInstanceId = UUID().uuidString //RCt7MfWyaM
        UserDefaults.standard.setValue(playerInstanceId, forKey: "playerInstanceId")
        callPlayerData(propertyId, playerAV: self.player, videoUrl: video_url,customerPlayerData:customerPlayerData)
    }
    
    //MARK:- Player Data
    func callPlayerData(_ gumletEnvironmentKey:String, playerAV:AVPlayer, videoUrl:String,customerPlayerData:GumletInsightsCustomPlayerData)
   {
        callIds()
        playerInstanceId = UserDefaults.standard.value(forKey: "playerInstanceId") as! String
        let screenBounds = getScreenBounds()
        screenWidth = Int(screenBounds.size.width)
        screenHeight = Int(screenBounds.size.height)
        let language = NSLocale.preferredLanguages.first
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
        let playerData = customerPlayerData
        let pageType = playerData.gumletPageType
        let playerIntegrationVersion = playerData.GumletPlayerIntegrationVersion
        let playerName = playerData.GumletPlayerName
        videAnaManager.callPlayerAPI(sessionId: sessionId, userId: uniqueId, playerInstaceId: playerInstanceId, playerHeight: screenHeight, playerWidth: screenWidth, pageType: pageType, pageUrl: bundleId, playerSoftware: playerSoftware, playerLanguageCode: playerLanguage, playerName: playerName, playerIntegrationVersion: playerIntegrationVersion, playerSoftwareVersion: PlayerSoftwareVersion, playerPreload: isPreload, gumletEnvironmentKey: gumletEnvironmentKey,localCurrentTime:currentTimeEpoch,orientation: deviceOrientation,customUserId:"")
    }
    
    
    //MARK:  Events API
    func callEventsAPI(eventTime : Double, previousEvents:String, eventName:String)
    {
        callIds()
        UserDefaults.standard.setValue(previousEvents, forKey: "previousEvents")
        playBackId = UserDefaults.standard.value(forKey: "playBackId") as! String
        let localCurrentTime = getDate()
        currentTimeEpoch = (((Date().timeIntervalSince1970) * 1000)/1000).roundToDecimal(3)
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
        meta_CDN = getHostName(videoUrl: videoSourceUrl)
        let event_current_time = eventTime
        videoTotalTime = getTotalVideoDuration()
        UserDefaults.standard.setValue(videoTotalTime, forKey: "videoTotalTime")
        let gumlet_Environment_Key = UserDefaults.standard.value(forKey: "EnvironmentKey")
        videoSourceUrl = UserDefaults.standard.value(forKey: "video_url") as! String
        videoSourceType = getVideoSourceType(VideoUrl:videoSourceUrl)
        let upscale = upScale(playerWidth: player_width, videoWidth: videoWidth)
        let downscale = downScale(playerWidth: player_width, videoWidth: videoWidth)
        playerInstanceId = UserDefaults.standard.value(forKey: "playerInstanceId") as! String
        if isEventsetup == true
        {
            UserDefaults.standard.setValue(localCurrentTime, forKey: "localCurrentTimePrevEvent")
            let previousEventTime = getLastEventsTime()
            UserDefaults.standard.setValue(previousEventTime, forKey: "previousEventTime")
            videAnaManager.callEventAPI(eventId: eventId, sessionId: sessionId, userId:uniqueId, playbackId: playBackId, playerInstaceId: playerInstanceId, event:eventName, startPlayTimeInMS:event_current_time, videoDownScale: 0.0, videoUpscale: 0.0, bitrateMbps:indicatedBitrate, playerRemotePlayed: "true", videoSourceDomain: meta_CDN, videoTotalDuration: videoTotalTime, videoWidthPixel:videoWidth, videoHeightPixel:videoHeight, videoSourceUrl: videoSourceUrl, videoSourceHostName: meta_CDN, videoSourceType: videoSourceType, muted:player.isMuted, previousEvent: previousEvents, previousEventTime: previousEventTime, gumletEnvironmentKey: gumlet_Environment_Key as! String,localCurrentTime:currentTimeEpoch,orientation: deviceOrientation,orientation_from:prevDeviceOrientation,fullscreen:isFullScreen,quality:"NO",errorMsg:"",errorTitle:"",errorCode:0)
            }
            else if isEventsetup == false
            {
                let previousEventTime = getLastEventsTime()
                UserDefaults.standard.setValue(previousEventTime, forKey: "previousEventTime")
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
        let minutString = time / 60
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
        if prevEventTime == "0"
        {
        }
        else
        {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS"//this your string date format
            dateFormatter.timeZone = NSTimeZone(name: "UTC") as TimeZone?
            let dated = dateFormatter.date(from: prevEventTime )
            prevTime = Int(dated!.timeIntervalSince1970 * 1000)
        }
     
        let localCurrentTimeEvent = UserDefaults.standard.value(forKey: "localCurrentTime")as! String
        let dFormatter = DateFormatter()
        dFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS"//this your string date format
        dFormatter.timeZone = NSTimeZone(name: "UTC") as TimeZone?
        let dated1 = dFormatter.date(from: localCurrentTimeEvent)
        let lTime = Int(dated1!.timeIntervalSince1970 * 1000)
        let diff = lTime - prevTime
        UserDefaults.standard.setValue(localCurrentTimeEvent, forKey: "localCurrentTimePrevEvent")
        return Float(diff)
    }
    
    //MARK:- get total video duration
    public func getTotalVideoDuration() -> Double
    {
        let seconds = (player.currentItem?.asset.duration)
        let  video_total_time = CMTimeGetSeconds(seconds!)
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
               return
            }
            let uiImage = UIImage(cgImage: cgImage)
            UIImageWriteToSavedPhotosAlbum(uiImage, nil, nil, nil);
        })
    }
    
    
    //MARK:-- video size
  public func getVideoResolution() -> CGSize?
  {
        let size = (self.player.currentItem?.presentationSize)
        return size
  }
    
//MARK:- screen size
   public func getScreenBounds() -> CGRect
    {
        return UIScreen.main.bounds
    }
    
    //MARK:- Player view size
    func getPlayerViewBounds() -> CGRect
    {
        return controller.view.bounds
    }
    
    //MARK:- get device Orientation
    @objc func rotated() -> String
    {
        let eventHandler = EventHandler()
        eventHandler.playerCore = self
        if UIScreen.main.bounds.width < UIScreen.main.bounds.height
        {
            deviceOrientation = "Portrait"
            if(isOrientationChange == true)
            {
                prevDeviceOrientation = "Landscape"
                play_current_time = getPlay_Pause_Time()
                let currentStates = UserDefaults.standard.value(forKey: "currentState") as! String
                eventHandler.callDeviceOrientation(currentState: currentStates, playCurrentTime: play_current_time)
            }
        }
        else if UIScreen.main.bounds.width > UIScreen.main.bounds.height
        {
            deviceOrientation = "Landscape"
            if (isOrientationChange == false)
            {
                prevDeviceOrientation = "Portrait"
                play_current_time = getPlay_Pause_Time()
                let currentStates = UserDefaults.standard.value(forKey: "currentState") as! String
                eventHandler.callDeviceOrientation(currentState: currentStates, playCurrentTime: play_current_time)
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
            upScale = (abs((playerWidth - videoWidth)/videoWidth)*100)
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
            downScale = (abs((playerWidth - videoWidth)/videoWidth)*100)
        }
        else{
            downScale = 0.0
        }
        return downScale
    }
    
    //MARK:-- get date
    func getDate() -> String
    {
        let date = Date()
        let df = DateFormatter()
        df.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS"
        df.timeZone = NSTimeZone(name: "UTC") as TimeZone?
        let dateString = df.string(from: date)
        return dateString
    }
    
    //MARK:-- get current Time in Epoch
    public func currentEpochTime() -> Double
    {
        return (((Date().timeIntervalSince1970) * 1000)/1000).roundToDecimal(3)
    }
    
    //MARK:-- get current Playhead Time in Ms
    func getCurrentPlayheadTimeMs() -> Double {
        return CMTimeGetSeconds(player.currentTime()) * 1000;
    }
    
    
    //set the timer, which will update your progress bar. You can use whatever time interval you want
    //MARK:--  calculate Bandwidth Metric
    func calculateBandwidthMetricFromAccessLog(log:AVPlayerItemAccessLog)
    {
        if isplaybackFinish == false{
            if log != nil && log.events.count > 0
            {
                //https://developer.apple.com/documentation/avfoundation/avplayeritemaccesslogevent?language=objc
                let event : AVPlayerItemAccessLogEvent? = log.events[log.events.count - 1]
                if (_lastTransferEventCount != log.events.count) {
                    _lastTransferDuration = 0
                    _lastTransferredBytes = 0
                    _lastTransferEventCount = Int8(log.events.count);
                }
                let request_start = Int(Date().timeIntervalSince1970)
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
                //https://developer.apple.com/documentation/avfoundation/avplayeritemaccesslogevent?language=objc
                let event : AVPlayerItemAccessLogEvent? = log.events[log.events.count - 1]
                if (_lastTransferEventCount != log.events.count) {
                    _lastTransferDuration = 0
                    _lastTransferredBytes = 0
                    _lastTransferEventCount = Int8(log.events.count);
                }
                let request_start = Int(Date().timeIntervalSince1970)//getDate()
                let request_response_start = Int(Date().timeIntervalSince1970)//getDate()
                let request_response_end  = Int(Date().timeIntervalSince1970)
                let request_bytes_loaded :Int64 =  Int64(event!.numberOfBytesTransferred) - (_lastTransferredBytes)
                let request_type = "event_requestcanceled"
                let request_response_headers = "";
                var requestHostName :String? = ""
                if requestHostName != nil{
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
    }
    
    //MARK:--  check Video Quality Change
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
    
    //MARK:--  check Mute And Unmute
    func checkMuteAnUnmute()
    {
        let eventHandler = EventHandler()
        eventHandler.playerCore = self
        if videoMuted == false {
            if player.isMuted == true
            {
                play_current_time = getPlay_Pause_Time()
                let currentStates = UserDefaults.standard.value(forKey: "currentState") as! String
                eventHandler.callMute(currentState: currentStates, playCurrentTime: play_current_time)
                videoMuted = true
            }
        }
        else if player.isMuted == false
        {
            if videoUnMuted == true
            {
               play_current_time = getPlay_Pause_Time()
                let currentStates = UserDefaults.standard.value(forKey: "currentState") as! String
                eventHandler.callUnmute(currentState: currentStates, playCurrentTime: play_current_time)
                videoUnMuted = false
            }
        }
    }
    
    //MARK:--  check For Seek Event
    func checkForSeekEvent()
    {
        let playheadTimeElapsed :Double = (getCurrentPlayheadTimeMs() - Double(lastUpdateTime)) / 1000;
        let wallTimeElapsed : Double = CFAbsoluteTimeGetCurrent() - Double(timeOfUpdate)
        let drift = playheadTimeElapsed - wallTimeElapsed;
        if fabsf(Float(playheadTimeElapsed)) > 0.5 &&
            fabsf(Float(drift)) > 0.2 &&
            (currentState == GumletPlayerStateMachine.GumletPlayerStatePaused.rawValue || currentState == GumletPlayerStateMachine.GumletPlayerStatePlay.rawValue) {
            if isSeeking == false{
                isSeeking = true
                let seekStartTimestamp = getDate()
                UserDefaults.standard.setValue(seekStartTimestamp, forKey: "seekStartTimestamp")
            }
        }
        else{
            if isSeeking == true{
                isSeeking = false
               let  play_current_time_seek_end = getPlay_Pause_Time()
            }
        }
    }
    
    //MARK:--  update Last Playhead Time
    func updateLastPlayheadTime() {
        lastUpdateTime = Float(getCurrentPlayheadTimeMs())
        timeOfUpdate = CFAbsoluteTimeGetCurrent()
    }
    
    //MARK:--  update Last Playhead Time for test
    public func getPreviousEventName() -> String
    {
        guard let prevEvent = UserDefaults.standard.string(forKey:"previousEvents") else { return  ""}
        return prevEvent
    }
    
    //MARK:--  update Last Playhead Time for test
    public func getPreviousTime() -> Int
    {
        let previousTime = UserDefaults.standard.integer(forKey: "previousEventTime")
        return previousTime
    }
    
    //MARK:-- de init
    deinit
    {
        UserDefaults.standard.removeObject(forKey: "video_url")
        UserDefaults.standard.removeObject(forKey: "playBackId")
        UserDefaults.standard.removeObject(forKey: "playerInstanceId")
    }
}

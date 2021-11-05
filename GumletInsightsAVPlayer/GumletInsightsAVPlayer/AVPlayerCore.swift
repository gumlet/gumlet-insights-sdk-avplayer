//
//  AVPlayerCore.swift
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
    
    enum Events : String
    {
        case isPlayerSetup = "event_player_setup"
        case isPlayerReady = "event_player_ready"
        case isPlay = "event_play"
        
        case isPlaying = "event_playing"
        case isPlaybackStarted = "event_playback_started"
        case isUpdatePlayback = "event_playback_update"
        
        case isPaused = "event_paused"
        case isBufferingStart = "event_rebuffer_start"
        case isBufferingEnd = "event_rebuffer_end"
        
        case isEnd = "event_end"
        //        case isSeeking = "event_seeking"
        case isSeek = "event_seeked"
        
        case isMute = "event_mute"
        case isUnMute = "event_unmute"
        case isFullScreenStart = "event_fullscreen_started"
        
        case isFullScreenEnd = "event_fullscreen_ended"
        case isDeviceOrientationChange = "event_device_orientation_changed"
        case isScreenCastStart = "event_casting_started"
        
        case isScreenCastEnd = "event_casting_ended"
        case isVideochange = "event_video_change"
        case isQualityChange = "event_quality_change"
        case isEventError = "event_error"
    }
    
    
    enum GumletPlayerState : String {
        
        case GumletPlayerStateReady = "Ready"
        case GumletPlayerStateViewinit = "Init"
        case GumletPlayerStatePlay = "Play"
        
        
        case GumletPlayerStateBuffering = "Buffering"
        case GumletPlayerStatePlaying = "Playing"
        case GumletPlayerStatePaused = "Paused"
        
        case GumletPlayerStateError = "Error"
        case GumletPlayerStateViewEnd = "End"
        
    }
    
    
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
    
    var _lastTransferEventCount : Int8 = 0
    var _lastTransferDuration : Double = 0.0
    var _lastTransferredBytes : Int64 = 0
    
    var isBuffer :Bool = false
    var isSeeking :Bool = false
    var isOrientationChange: Bool = false
    var isEventsetup : Bool = true
    var isQualitychange :Bool = false
    
    var videoMuted :Bool = false
    var videoUnMuted : Bool = false
    var isFullScreen :Bool = false
    var isPlaybackStarted :Bool = false
    var isplaybackFinish :Bool = false
    var isorientationFirst : Bool = true
    
    var errorTitle:String = ""
    var errorMessage:String = ""
    var errorCode = 0
    
    // init Gumlet Video Manager
    var videAnaManager = GumletInsightsManager()
    // init player
    var player = AVPlayer()
    let controller = AVPlayerViewController()
    //    var currentItem = AVPlayerItem?()
    var currentPlayerItem: AVPlayerItem?
    var timer = Timer()
    var webViewForUserAgent: WKWebView?
    
    
    
    
    
    
    //    public override func viewDidLoad() {
    //        super.viewDidLoad()
    //        // Do any additional setup after loading the view.26911E3B-F65B-46F1-AB5F-498510E99467-26-09-2021
    //    }
    
    //MARK:- Create IDs
    public class func randomStringForId(_ n: Int) -> String
    {
        let  digits = "abcdefghijklmnopqrstuvwxyz1234567890ABCDEFGHIJKLMNOPQRSTUVWXYZ"
        
        return String(Array(0..<n).map{
            _ in digits.randomElement()!
        })
    }
    
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
        let session_Id = AVPlayerCore.randomStringForId(10)
        
        UserDefaults.standard.setValue(session_Id, forKey: "user_session")
        UserDefaults.standard.set(Date(), forKey:"user_session_creation_time")
        return session_Id
    }
    
    func checkSessionId() -> String
    {
        if let session_id = UserDefaults.standard.string(forKey: "user_session") {
            
            if let date = UserDefaults.standard.object(forKey: "user_session_creation_time") as? Date{
                if let diff = Calendar.current.dateComponents([.hour], from: date, to: Date()).hour, diff > 12
                {
                    _ = Calendar.current.dateComponents([.hour], from: date, to: Date()).hour
                    
                    return createSessionId()
                }
            }
            return session_id
            
        }
        else{
            return createSessionId()
        }
    }
    
    func createEventId() -> String
    {
        let event_id = AVPlayerCore.randomStringForId(10)
        
        return event_id
    }
    
    func createNetworkRequestId() -> String
    {
        let request_id = AVPlayerCore.randomStringForId(10)
        
        return request_id
    }
    
    
    func createPlayBackId() -> String
    {
        let play_back_id = AVPlayerCore.randomStringForId(10)
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
    func createPlayerInstanceId() -> String
    {
        let player_instance_id = AVPlayerCore.randomStringForId(10)
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
    func createUniqueId() -> String
    {
        let userId = UIDevice.current.identifierForVendor!.uuidString
        let index = userId.firstIndex(of: "-") ?? userId.endIndex
        let beginning = userId[..<index]
        let unique_id = String(beginning)
        
        saveUniqueId(uniqueId:unique_id)
        return unique_id
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
        callEventSetUp(videoURL: video_url!.absoluteString)
        
        
        self.player.addObserver(self, forKeyPath: "status", options: [.old, .new], context: nil)
        self.player.addObserver(self, forKeyPath: "rate", options: [.old, .new], context: nil)
        self.player.addObserver(self, forKeyPath: "timeControlStatus", options: [.old, .new], context: nil)
        
        //        self.player.addObserver(self, forKeyPath: #keyPath(AVPlayer.currentItem.status), options:[.new, .old], context:nil)
        
        
        NotificationCenter.default.addObserver(self, selector:#selector(self.playerDidFinishPlaying),name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: player.currentItem)
        //
        
        NotificationCenter.default.addObserver(self, selector:#selector(self.receiveAirPlayNotification(note:)),name: UIScreen.didConnectNotification, object: nil)
        
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(handleAVPlayerAccess),name: NSNotification.Name.AVPlayerItemNewAccessLogEntry,
                                               object: nil)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(handleAVPlayerError),name: NSNotification.Name.AVPlayerItemNewErrorLogEntry,
                                               object: nil)
        
        
        
        
        
    }
    
    public func callEventSetUp(videoURL:String)
    {
        isPlaybackStarted = false
        
        
        isEventsetup = true
        
        eventName = Events.isPlayerSetup.rawValue
        let prevEvents = ""
        
        UserDefaults.standard.setValue(eventName, forKey: "eventName")
        play_current_time = getPlay_Pause_Time()
        
        callEventsAPI(eventTime: play_current_time, previousEvents:prevEvents)
        
        
        if let url = UserDefaults.standard.string(forKey: "video_url"), url != videoURL{
            playBackId = AVPlayerCore.randomStringForId(10)
            
            UserDefaults.standard.setValue(playBackId, forKey: "playBackId")
            callVideoChange()
        }
        UserDefaults.standard.setValue(videoURL, forKey: "video_url")
        
        
        
    }
    
    
    public func playerReady()
    {
        
        
        
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
                weakSelf.updateLastPlayheadTime()
                
            })
        }
        
    }
    
    public func callPlay()
    {
        
        if videoMuted == false {
            
            if player.isMuted == true{
                callMute()
                videoMuted = true
            }
        }
        
        
        
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
        
        
        
        eventName = Events.isPlaying.rawValue
        
        let prevEvents = UserDefaults.standard.value(forKey: "eventName") as! String
        
        UserDefaults.standard.setValue(eventName, forKey: "eventName")
        
        
        
        play_current_time = getPlay_Pause_Time()
        
        UserDefaults.standard.setValue(play_current_time, forKey: "seekedTime")
        callEventsAPI(eventTime: play_current_time, previousEvents:prevEvents)
        
        
        
        if isPlaybackStarted == false
        {
            callPlaybackStarted()
            isPlaybackStarted = true
        }
        
        
        updatePlaybackEvent()
        
        
        
        
        
    }
    
    public func callPause()
    {
        
        timer.invalidate()
        timer = Timer()
        
        if videoMuted == false {
            
            if player.isMuted == true{
                callMute()
                videoMuted = true
            }
        }
        else if player.isMuted == false
        {
            if videoUnMuted == true
            {
                callUnmute()
                videoUnMuted = false
            }
            
        }
        
        
        
        
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
        
        eventName = Events.isBufferingStart.rawValue
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
        
        eventName = Events.isFullScreenEnd.rawValue
        let prevEvents = UserDefaults.standard.value(forKey: "eventName") as! String
        
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
        eventName = Events.isScreenCastStart.rawValue
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
        
        eventName = Events.isScreenCastEnd.rawValue
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
        eventName = Events.isQualityChange.rawValue
        let prevEvents = UserDefaults.standard.value(forKey: "eventName") as! String
        
        
        UserDefaults.standard.setValue(eventName, forKey: "eventName")
        
        
        
        play_current_time = getPlay_Pause_Time()
        
        callEventsAPI(eventTime: play_current_time, previousEvents:prevEvents)
    }
    
    func callSeekEvent()
    {
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
        
        play_current_time = getPlay_Pause_Time()
        
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
        
        if videoMuted == false {
            
            if player.isMuted == true{
                callMute()
                videoMuted = true
            }
        }
        else if player.isMuted == false
        {
            if videoUnMuted == true
            {
                callUnmute()
                videoUnMuted = false
            }
            
        }
    }
    
    
    
    @objc func playerDidFinishPlaying(){
        
        
        isplaybackFinish = true
        
        
        eventName = Events.isEnd.rawValue
        let prevEvents = UserDefaults.standard.value(forKey: "eventName") as! String
        
        
        UserDefaults.standard.setValue(eventName, forKey: "eventName")
        
        play_current_time = getPlay_Pause_Time()
        
        callEventsAPI(eventTime: play_current_time, previousEvents:prevEvents)
        
        
    }
    
    //Forcing playback again.
    @objc func playerStalled(note: NSNotification) {
        
        let playerItem = note.object as! AVPlayerItem
        if let player = playerItem.value(forKey: "player") as? AVPlayer{
            player.play()
        }
        
        
        
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
                
                
                let request_start = getDate()
                let request_response_start = getDate()
                
                let request_response_end  = getDate()
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
        if indicatedBitrate != Float(lastEvent.indicatedBitrate){
            
            
            indicatedBitrate = Float(lastEvent.indicatedBitrate)
            callVideoQualityChange()
        }
        
        let isNotificationRelevant :Bool = checkIfNotificationIsRelevant(notif: notification as NSNotification)
        
        if (isNotificationRelevant) {
            
            
            let playerItem = notification.object as? AVPlayerItem
            let accessLog = playerItem!.accessLog()
            
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
        //Do whatever you want here, or call another function
        
        callScreenCastStart()
        
    }
    
    
    //MARK:- call key value observer for play and pause event
    public override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?)
    {
        
        if object as AnyObject? === player {
            //           / callEventSetUp()
            if keyPath == "status" {
                if player.status == .readyToPlay
                {
                    playerReady()
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
                    state = GumletPlayerState.GumletPlayerStatePlay.rawValue
                    callPlay()
                }
                else if player.rate == 0.0
                {
                    state = GumletPlayerState.GumletPlayerStatePaused.rawValue
                    callPause()
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
                    callPlaying()
                    
                    
                }
                else if player.timeControlStatus == .paused
                {
                    print("timeControl paused")
                }
                else if player.timeControlStatus == .waitingToPlayAtSpecifiedRate
                {
                    
                    //                bufferState()
                    if isBuffer == false{
                        
                        callBufferingStart()
                        isBuffer = true
                    }
                    
                }
            }
            
            
        }
        
    }
    
    //MARK:- init SDK
    
    public func init_SDK(propertyId:String)
    {
        
        callIds()
        
        let url: URL? = (player.currentItem?.asset as? AVURLAsset)?.url
        let video_url = url!.absoluteString
        
        
        let localCurrentTime = getDate()
        let screenBounds = getScreenBounds()
        screenWidth = Int(Float(screenBounds.size.width))
        screenHeight = Int(Float(screenBounds.size.height))
        
        deviceOrientation = "Portrait"//rotated()
        UserDefaults.standard.setValue(deviceOrientation, forKey: "deviceOrientation")
        //           prevDeviceOrientation = deviceOrientation
        
        
        
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
        UserDefaults.standard.setValue("", forKey: "video_url")
        
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
        videAnaManager.callSessionAPI(sessionId: sessionId, userId: uniqueId,  metaDeviceArch: meta_device_Arch, userName: userName, userEmail: userEmail, userCity: userCity,userPhone:userPhone,userAddLineOne:userAddLineOne,userAddLineTwo:userAddLineTwo,userState:userState,userZipCode:userZipCode,userCountry:userCountry, gumletEnvironmentKey: propertyId, version: operating_system_version, platform: operating_system, deviceCategory: device_category, deviceManufacturer: device_manufacturer, deviceName: device_name, deviceWidth:screenWidth , deviceDisplayPPI: device_display_ppi, deviceHeight: screenHeight, deviceIsTouchable: device_is_touchscreen,localCurrentTime:localCurrentTime,orientation: deviceOrientation, customUserId: "")
        
        
        playerInstanceId = AVPlayerCore.randomStringForId(10)
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
        
        if ((language) != nil) {
            playerLanguage  = language!
        }
        else
        {
            playerLanguage  = "English"
        }
        
        deviceOrientation = "Portrait"
        UserDefaults.standard.setValue(deviceOrientation, forKey: "deviceOrientation")
        
        
        
        
        let videoURL = NSURL(string:videoSourceUrl)
        let asset = AVAsset(url:videoURL! as URL)
        
        for characteristic in asset.availableMediaCharacteristicsWithMediaSelectionOptions {
            // Retrieve the AVMediaSelectionGroup for the specified characteristic.
            if let group = asset.mediaSelectionGroup(forMediaCharacteristic: characteristic) {
                // Print its options.
                for option in group.options {
                    
                    
                    _ = option.displayName
                    
                }
            }
        }
        
        let isPreload = "true"
        
        let bundleId = Bundle.main.bundleIdentifier!
        
        
        let playerSoftware =  "AVPlayer"
        
        let PlayerSoftwareVersion = "AVKit"
        
        
        let localCurrentTime = getDate()
        
        
        let playerData = GumletInsightsCustomPlayerData()
        let pageType = playerData.gumletPageType
        let playerIntegrationVersion = playerData.GumletPlayerIntegrationVersion
        let playerName = playerData.GumletPlayerName
        
        videAnaManager.callPlayerAPI(sessionId: sessionId, userId: uniqueId, playerInstaceId: playerInstanceId, playerHeight: screenHeight, playerWidth: screenWidth, pageType: pageType, pageUrl: bundleId, playerSoftware: playerSoftware, playerLanguageCode: playerLanguage, playerName: playerName, playerIntegrationVersion: playerIntegrationVersion, playerSoftwareVersion: PlayerSoftwareVersion, playerPreload: isPreload, gumletEnvironmentKey: gumletEnvironmentKey,localCurrentTime:localCurrentTime,orientation: deviceOrientation,customUserId:"")
        
        
        
    }
    
    
    //MARK:  Events API
    func callEventsAPI(eventTime : Double, previousEvents:String)
    {
        callIds()
        
        playerInstanceId = UserDefaults.standard.value(forKey: "playerInstanceId") as! String
        
        
        playBackId = UserDefaults.standard.value(forKey: "playBackId") as! String
        
        
        let localCurrentTime = getDate()
        
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
        
        
        
        deviceOrientation = rotated()
        UserDefaults.standard.setValue(deviceOrientation, forKey: "deviceOrientation")
        
        
        NotificationCenter.default.addObserver(self, selector: #selector(rotated), name: UIDevice.orientationDidChangeNotification, object: nil)
        
        
        videoSourceUrl = UserDefaults.standard.value(forKey: "video_url") as! String
        
        videoSourceType = getVideoSourceType(VideoUrl:videoSourceUrl)
        
        
        
        
        meta_CDN = getHostName(videoUrl: videoSourceUrl)
        let event_current_time = eventTime
        
        
        videoTotalTime = getTotalVideoDuration()
        let gumlet_Environment_Key = UserDefaults.standard.value(forKey: "EnvironmentKey")
        
        
        
        let upscale = upScale(playerWidth: player_width, videoWidth: videoWidth)
        let downscale = downScale(playerWidth: player_width, videoWidth: videoWidth)
        
//        let videoData = GumletInsightsCustomVideoData()
//        _ = videoData.customVideotitle
        //        _ = videoData.customVideoId
        //        _ = videoData.customVideoProducer
//
        if isEventsetup == true
        {
            UserDefaults.standard.setValue(localCurrentTime, forKey: "localCurrentTimePrevEvent")
            let previousEventTime = getLastEventsTime()
            
            videAnaManager.callEventAPI(eventId: eventId, sessionId: sessionId, userId:uniqueId, playbackId: playBackId, playerInstaceId: playerInstanceId, event:eventName, startPlayTimeInMS:event_current_time, videoDownScale: 0.0, videoUpscale: 0.0, bitrateMbps:indicatedBitrate, playerRemotePlayed: "true", videoSourceDomain: meta_CDN, videoTotalDuration: videoTotalTime, videoWidthPixel:videoWidth, videoHeightPixel:videoHeight, videoSourceUrl: videoSourceUrl, videoSourceHostName: meta_CDN, videoSourceType: videoSourceType, muted:player.isMuted, previousEvent: previousEvents, previousEventTime: previousEventTime, gumletEnvironmentKey: gumlet_Environment_Key as! String,localCurrentTime:localCurrentTime,orientation: deviceOrientation,orientation_from:prevDeviceOrientation,fullscreen:isFullScreen,quality:"NO",errorMsg:"",errorTitle:"",errorCode:0)
        }
        else if isEventsetup == false
        {
            let previousEventTime = getLastEventsTime()
            
            
            if isPlaybackStarted == true
            {
                
                if isQualitychange == true
                
                {
                    
                    
                    if isOrientationChange == true || isOrientationChange == false{
                        
                        videAnaManager.callEventAPI(eventId: eventId, sessionId: sessionId, userId:uniqueId, playbackId: playBackId, playerInstaceId: playerInstanceId, event:eventName, startPlayTimeInMS:event_current_time, videoDownScale: downscale, videoUpscale: upscale, bitrateMbps:indicatedBitrate, playerRemotePlayed: "true", videoSourceDomain: meta_CDN, videoTotalDuration: videoTotalTime, videoWidthPixel:videoWidth, videoHeightPixel:videoHeight, videoSourceUrl: videoSourceUrl, videoSourceHostName: meta_CDN, videoSourceType: videoSourceType, muted: player.isMuted, previousEvent: previousEvents, previousEventTime: previousEventTime, gumletEnvironmentKey: gumlet_Environment_Key as! String,localCurrentTime:localCurrentTime,orientation: deviceOrientation,orientation_from:prevDeviceOrientation,fullscreen:isFullScreen,quality:"true",errorMsg: errorMessage,errorTitle:errorTitle,errorCode:errorCode)
                    }
                    else{
                        videAnaManager.callEventAPI(eventId: eventId, sessionId: sessionId, userId:uniqueId, playbackId: playBackId, playerInstaceId: playerInstanceId, event:eventName, startPlayTimeInMS:event_current_time, videoDownScale: downscale, videoUpscale: upscale, bitrateMbps:indicatedBitrate, playerRemotePlayed: "true", videoSourceDomain: meta_CDN, videoTotalDuration: videoTotalTime, videoWidthPixel:videoWidth, videoHeightPixel:videoHeight, videoSourceUrl: videoSourceUrl, videoSourceHostName: meta_CDN, videoSourceType: videoSourceType, muted: player.isMuted, previousEvent: previousEvents, previousEventTime: previousEventTime, gumletEnvironmentKey: gumlet_Environment_Key as! String,localCurrentTime:localCurrentTime,orientation: deviceOrientation,orientation_from:"",fullscreen:isFullScreen,quality:"true",errorMsg: errorMessage,errorTitle:errorTitle,errorCode:errorCode)
                    }
                }
                else if isQualitychange == false
                {
                    videAnaManager.callEventAPI(eventId: eventId, sessionId: sessionId, userId:uniqueId, playbackId: playBackId, playerInstaceId: playerInstanceId, event:eventName, startPlayTimeInMS:event_current_time, videoDownScale: downscale, videoUpscale: upscale, bitrateMbps:indicatedBitrate, playerRemotePlayed: "true", videoSourceDomain: meta_CDN, videoTotalDuration: videoTotalTime, videoWidthPixel:videoWidth, videoHeightPixel:videoHeight, videoSourceUrl: videoSourceUrl, videoSourceHostName: meta_CDN, videoSourceType: videoSourceType, muted: player.isMuted, previousEvent: previousEvents, previousEventTime: previousEventTime, gumletEnvironmentKey: gumlet_Environment_Key as! String,localCurrentTime:localCurrentTime,orientation: deviceOrientation,orientation_from:prevDeviceOrientation,fullscreen:isFullScreen,quality:"false",errorMsg: errorMessage,errorTitle:errorTitle,errorCode:errorCode)
                }
            }
            
            else if isPlaybackStarted == false
            {
                //need to add quality change flag , but put flag after sometime
                videAnaManager.callEventAPI(eventId: eventId, sessionId: sessionId, userId:uniqueId, playbackId: playBackId, playerInstaceId: playerInstanceId, event:eventName, startPlayTimeInMS:event_current_time, videoDownScale: 0.0, videoUpscale: 0.0, bitrateMbps:indicatedBitrate, playerRemotePlayed: "true", videoSourceDomain: meta_CDN, videoTotalDuration: videoTotalTime, videoWidthPixel:videoWidth, videoHeightPixel:videoHeight, videoSourceUrl: videoSourceUrl, videoSourceHostName: meta_CDN, videoSourceType: videoSourceType, muted: player.isMuted, previousEvent: previousEvents, previousEventTime: previousEventTime, gumletEnvironmentKey: gumlet_Environment_Key as! String,localCurrentTime:localCurrentTime,orientation: deviceOrientation,orientation_from:"",fullscreen:isFullScreen,quality:"NO",errorMsg:errorMessage,errorTitle:errorTitle,errorCode:errorCode)
            }
            
        }
        
    }
    
    
    
    
    
    
    
    //MARK:- seek event API
    func callSeekEventsAPI(eventTime : Double, previousEvents:String, seekingTime:Double,seekedTime:Double)
    {
        callIds()
        //        getBitrate()
        playerInstanceId = UserDefaults.standard.value(forKey: "playerInstanceId") as! String
        
        playBackId = UserDefaults.standard.value(forKey: "playBackId") as! String
        
        let localCurrentTime = getDate()
        
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
        let previousEventTime = getSeekLatency()
        
        if isOrientationChange == true || isOrientationChange == false
        {
            
            videAnaManager.callSeekEventAPI(eventId: eventId, sessionId: sessionId, userId:uniqueId, playbackId: playBackId, playerInstaceId: playerInstanceId, event:eventName,seekingtime: seekingTime, seekedTime: seekedTime, startPlayTimeInMS:event_current_time, videoDownScale: downscale, videoUpscale: upscale, bitrateMbps:indicatedBitrate, playerRemotePlayed: "true", videoSourceDomain: meta_CDN, videoTotalDuration: videoTotalTime, videoWidthPixel:videoWidth, videoHeightPixel:videoHeight, videoSourceUrl: videoSourceUrl, videoSourceHostName: meta_CDN, videoSourceType: videoSourceType, muted: player.isMuted, previousEvent: previousEvents, previousEventTime: previousEventTime, gumletEnvironmentKey: gumlet_Environment_Key as! String,localCurrentTime:localCurrentTime,orientation: deviceOrientation,orientation_from:prevDeviceOrientation,fullscreen:isFullScreen,quality:"NO")
        }
        else{
            videAnaManager.callSeekEventAPI(eventId: eventId, sessionId: sessionId, userId:uniqueId, playbackId: playBackId, playerInstaceId: playerInstanceId, event:eventName,seekingtime: seekingTime, seekedTime: seekedTime, startPlayTimeInMS:event_current_time, videoDownScale: downscale, videoUpscale: upscale, bitrateMbps:Float(indicatedBitrate), playerRemotePlayed: "true", videoSourceDomain: meta_CDN, videoTotalDuration: videoTotalTime, videoWidthPixel:videoWidth, videoHeightPixel:videoHeight, videoSourceUrl: videoSourceUrl, videoSourceHostName: meta_CDN, videoSourceType: videoSourceType, muted: player.isMuted, previousEvent: previousEvents, previousEventTime: previousEventTime, gumletEnvironmentKey: gumlet_Environment_Key as! String,localCurrentTime:localCurrentTime,orientation: deviceOrientation,orientation_from:"",fullscreen:isFullScreen,quality:"NO")
        }
    }
    
    
    
    //MARK:- Network API
    func callNetworkAPI(requestStart:String, requestrResponseStart: String, requestResponseEnd: String, requestType: String, requestHostName: String, requestBytesLoaded: Int64, requestResponseHeaders: String, requestMediaDuration_millis: Int,  errorCode: Int, error: String, errorText: String)
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
        
        
        
        
        let localCurrentTime = getDate()
        let gumlet_Environment_Key = UserDefaults.standard.value(forKey: "EnvironmentKey")
        
        videAnaManager.callNetworkRequestAPI(request_id:networkRequestId, session_id:sessionId, user_id: uniqueId, source_id:gumlet_Environment_Key as! String, player_instance_id: playerInstanceId, request_start: requestStart, request_response_start: requestrResponseStart, request_response_end: requestResponseEnd, request_type: requestType, request_hostname: requestHostName, request_bytes_loaded: requestBytesLoaded, request_response_headers: requestResponseHeaders, request_media_duration_millis: requestMediaDuration_millis, request_video_width_pixels: videoWidth, request_video_height_pixels: videoHeight, error_code: errorCode, error: error, error_text: errorText, created_at: localCurrentTime)
    }
    
    
    
    
    //MARK:- get play and pause time
    func getPlay_Pause_Time() -> Double
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
        
        if prevEventTime == "0"
        {
            print("prevEventTime")
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
                
                return
            }
            let uiImage = UIImage(cgImage: cgImage)
            UIImageWriteToSavedPhotosAlbum(uiImage, nil, nil, nil);
        })
    }
    
    
    //MARK:-- video size
    func getVideoResolution() -> CGSize? {
        
        let size = (self.player.currentItem?.presentationSize)
        return size
        
    }
    
    func getScreenBounds() -> CGRect
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
    func upScale(playerWidth:Float,videoWidth:Float) -> Float
    {
        //playerwidth high and videoWidth less , means expand video width as per player width
        var upScale : Float = 0.0
        
        if (playerWidth > videoWidth)
        {
            upScale = (abs((playerWidth - videoWidth)/videoWidth)).roundToDecimalFloat(2)
            
        }
        else{
            upScale = 0.0
        }
        return upScale
    }
    
    //MARK:-- get downScale
    func downScale(playerWidth:Float,videoWidth:Float) -> Float
    {
        //playerwidth less and videoWidth high , means  compress video width as per player width
        
        var downScale : Float = 0.0
        if (playerWidth < videoWidth)
        {
            downScale = (abs((playerWidth - videoWidth)/videoWidth)).roundToDecimalFloat(2)
            
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
    
    func checkForSeekEvent(){
        
        
        let playheadTimeElapsed :Double = (getCurrentPlayheadTimeMs() - Double(lastUpdateTime)) / 1000;
        
        
        let wallTimeElapsed : Double = CFAbsoluteTimeGetCurrent() - Double(timeOfUpdate)
        
        
        let drift = playheadTimeElapsed - wallTimeElapsed;
        
        if fabsf(Float(playheadTimeElapsed)) > 0.5 &&
            fabsf(Float(drift)) > 0.2 &&
            (state == GumletPlayerState.GumletPlayerStatePaused.rawValue || state == GumletPlayerState.GumletPlayerStatePlay.rawValue) {
            if isSeeking == false{
                isSeeking = true
                let play_current_time = getPlay_Pause_Time()
                
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
                
                
                
                
                let request_start = getDate()//(requestStartSecs * 1000)
                
                let request_response_start = getDate()
                
                let request_response_end  = getDate()
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
                
                
                
                
                
                
                let request_start = getDate()
                
                let request_response_start = getDate()
                
                let request_response_end  = getDate()
                
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
    
    
    func getDownloadSize(url: URL, completion: @escaping (Int64, Error?) -> Void) {
        let timeoutInterval = 5.0
        var request = URLRequest(url: url,
                                 cachePolicy: .reloadIgnoringLocalAndRemoteCacheData,
                                 timeoutInterval: timeoutInterval)
        request.httpMethod = "HEAD"
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            
            
            let contentLength = response?.expectedContentLength ?? NSURLSessionTransferSizeUnknown
            completion(contentLength, error)
        }.resume()
    }
    
    
    func getSeekLatency()-> Float
    {
        var prevTime : Int = 0
        
        let prevEventTime = UserDefaults.standard.value(forKey: "seekStartTimestamp")as! String
        
        if prevEventTime == "0"
        {
            print("prevEventTime")
        }
        else
        {
            
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS"//this your string date format
            dateFormatter.timeZone = NSTimeZone(name: "UTC") as TimeZone?
            let dated = dateFormatter.date(from: prevEventTime )
            
            prevTime = Int(dated!.timeIntervalSince1970 * 1000)
            
            
            
        }
        
        let localCurrentTimeEvent = UserDefaults.standard.value(forKey: "seekTimeEnd")as! String
        
        
        let dFormatter = DateFormatter()
        dFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS"
        dFormatter.timeZone = NSTimeZone(name: "UTC") as TimeZone?
        let dated1 = dFormatter.date(from: localCurrentTimeEvent)
        let lTime = Int(dated1!.timeIntervalSince1970 * 1000)
        
        
        
        let diff = lTime - prevTime
        
        
        
        UserDefaults.standard.setValue(localCurrentTimeEvent, forKey: "localCurrentTimePrevEvent")
        
        return Float(diff)
    }
    
    deinit {
        
        print("deinint")
        UserDefaults.standard.removeObject(forKey: "video_url")
        
        UserDefaults.standard.removeObject(forKey: "playBackId")
        UserDefaults.standard.removeObject(forKey: "playerInstanceId")
        
    }
}

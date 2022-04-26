//
//  EventHandler.swift
//  GumletInsightsAVPlayer
//

//

import Foundation
import UIKit
import AVKit
import AVFoundation




public class EventHandler: NSObject {
    
    var eventName : String = ""
    var currentState : String = ""
   
    var isBuffer :Bool = false
    var isSeeking :Bool = false
    var isOrientationChange: Bool = false
    var videoUnMuted : Bool = false
    public var isPlaybackStarted :Bool = true
    let eventUpdatePlaybackTime = 3.0
    var gumletTranstion = GumletTransition()
    var player = AVPlayer()
    var playerCore: AVPlayerCore?
    
    public func callPlay(prevEvents:String, currentState:String, playCurrentTime:Double)
    {
        eventName = Events.isPlay.rawValue
        let state = gumletTranstion.transitionState(eventName: eventName, currentState: currentState, destinationState: GumletPlayerStateMachine.GumletPlayerStatePlay.rawValue)
        if state == true
        {
            UserDefaults.standard.setValue(eventName, forKey: "eventName")
            playerCore?.callEventsAPI(eventTime: playCurrentTime, previousEvents:prevEvents, eventName: eventName)
        }
        self.currentState = GumletPlayerStateMachine.GumletPlayerStatePlay.rawValue
    }
    
    public func callPause(currentState:String, playCurrentTime:Double)
    {
        playerCore?.timer?.invalidate()
        playerCore?.timer = nil
        eventName = Events.isPaused.rawValue
        let state = gumletTranstion.transitionState(eventName: eventName, currentState: currentState, destinationState: GumletPlayerStateMachine.GumletPlayerStatePaused.rawValue)
        if state == true
        {
        let prevEvents = UserDefaults.standard.value(forKey: "eventName") as! String
        UserDefaults.standard.setValue(eventName, forKey: "eventName")
        playerCore?.callEventsAPI(eventTime: playCurrentTime, previousEvents:prevEvents, eventName: eventName)
        }
        self.currentState = GumletPlayerStateMachine.GumletPlayerStatePaused.rawValue
       }
    

    public func callBufferingStart(currentState:String,playCurrentTime:Double)
    {
        playerCore?.timer?.invalidate()
        playerCore?.timer = nil
        eventName = Events.isBufferingStart.rawValue
        let state = gumletTranstion.transitionState(eventName: eventName, currentState: currentState, destinationState: GumletPlayerStateMachine.GumletPlayerStateBuffering.rawValue)
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
            isBuffer = true
            playerCore?.callEventsAPI(eventTime: playCurrentTime, previousEvents:prevEvents!, eventName: eventName)
        }
        self.currentState = GumletPlayerStateMachine.GumletPlayerStateBuffering.rawValue
    }
    
    public func callBufferingEnd(currentState:String,playCurrentTime:Double)
    {
        
        eventName = Events.isBufferingEnd.rawValue
        let state = gumletTranstion.transitionState(eventName: eventName, currentState: currentState, destinationState: GumletPlayerStateMachine.GumletPlayerStateBuffering.rawValue)
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
        playerCore?.callEventsAPI(eventTime: playCurrentTime, previousEvents:prevEvents!, eventName: eventName)
        }
        self.currentState = GumletPlayerStateMachine.GumletPlayerStateBuffering.rawValue
    }
    
    func callMute(currentState:String,playCurrentTime:Double)
    {
        videoUnMuted = true
        eventName = Events.isMute.rawValue
        let state = gumletTranstion.transitionState(eventName: eventName, currentState: currentState, destinationState: currentState)
        if state == true
        {
        let prevEvents = UserDefaults.standard.value(forKey: "eventName") as! String
        UserDefaults.standard.setValue(eventName, forKey: "eventName")
        playerCore?.callEventsAPI(eventTime: playCurrentTime, previousEvents:prevEvents, eventName: eventName)
        }
    }
    func callUnmute(currentState:String,playCurrentTime:Double)
    {
        eventName = Events.isUnMute.rawValue
        let state = gumletTranstion.transitionState(eventName: eventName, currentState: currentState, destinationState: currentState)
        if state == true
        {
            let prevEvents = UserDefaults.standard.value(forKey: "eventName") as! String
            UserDefaults.standard.setValue(eventName, forKey: "eventName")
            playerCore?.callEventsAPI(eventTime: playCurrentTime, previousEvents:prevEvents, eventName: eventName)
        }
    }
    func callFullScreenStart(currentState:String,playCurrentTime:Double)
    {
        eventName = Events.isFullScreenStart.rawValue
        let prevEvents = UserDefaults.standard.value(forKey: "eventName") as! String
        UserDefaults.standard.setValue(eventName, forKey: "eventName")
        playerCore?.callEventsAPI(eventTime: playCurrentTime, previousEvents:prevEvents, eventName: eventName)
    }

    func callFullScreenEnd(currentState:String,playCurrentTime:Double)
    {
        playerCore?.timer?.invalidate()
        playerCore?.timer = nil
        eventName = Events.isFullScreenEnd.rawValue
        let prevEvents = UserDefaults.standard.value(forKey: "eventName") as! String
        UserDefaults.standard.setValue(eventName, forKey: "eventName")
        playerCore?.callEventsAPI(eventTime: playCurrentTime, previousEvents:prevEvents, eventName: eventName)
    }

    func callDeviceOrientation(currentState:String,playCurrentTime:Double)
    {
        if (isOrientationChange == false)
        {
            isOrientationChange = true
            eventName = Events.isDeviceOrientationChange.rawValue
            let state = gumletTranstion.transitionState(eventName: eventName, currentState: currentState, destinationState: currentState)
            if state == true
            {
                var prevEvents :String? = ""
                if prevEvents == ""{
                prevEvents = ""
            }
            else
            {
                prevEvents = (UserDefaults.standard.value(forKey: "eventName") as! String)
            }
            UserDefaults.standard.setValue(eventName, forKey: "eventName")
            playerCore?.callEventsAPI(eventTime: playCurrentTime, previousEvents:prevEvents!, eventName: eventName)
            }
          }
          else if(isOrientationChange == true)
        {
            isOrientationChange = false
            eventName = Events.isDeviceOrientationChange.rawValue
            let state = gumletTranstion.transitionState(eventName: eventName, currentState: currentState, destinationState: currentState)
            if state == true
            {
                var prevEvents :String? = ""
                if prevEvents != nil{
                prevEvents = ""
            }
            else{
                prevEvents = (UserDefaults.standard.value(forKey: "eventName") as! String)
              }
            UserDefaults.standard.setValue(eventName, forKey: "eventName")
            playerCore?.callEventsAPI(eventTime: playCurrentTime, previousEvents:prevEvents!, eventName: eventName)
            }
          }
    }


    func callScreenCastStart(playCurrentTime:Double)
    {
        playerCore?.timer?.invalidate()
        playerCore?.timer = nil
        var prevEvents :String? = ""
        if prevEvents != nil{
            prevEvents = (UserDefaults.standard.value(forKey: "eventName") as! String)
        }
        else{
            prevEvents = ""
            }
        UserDefaults.standard.setValue(eventName, forKey: "eventName")
        playerCore?.callEventsAPI(eventTime: playCurrentTime, previousEvents:prevEvents!, eventName: eventName)
    }

    func callScreenCastEnd(playCurrentTime:Double)
    {
        playerCore?.timer?.invalidate()
        playerCore?.timer = nil
        var prevEvents :String? = ""
        if prevEvents != nil
        {
            prevEvents = (UserDefaults.standard.value(forKey: "eventName") as! String)
         }
        else{
            prevEvents = ""
        }
        UserDefaults.standard.setValue(eventName, forKey: "eventName")
        playerCore?.callEventsAPI(eventTime: playCurrentTime, previousEvents:prevEvents!, eventName: eventName)
    }
   
}

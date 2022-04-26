//
//  GumletTransition.swift
//  GumletSDKVidAnalytics
//
//  Created by Nishant Pandey on 15/11/21.
//

import Foundation

 class GumletTransition {
  
    func transitionState(eventName:String, currentState:String,destinationState:String) -> Bool {

            //print("[StateMachine] Transitioning from state \(currentState) to \(destinationState)")

        if (eventName == Events.isPlayerSetup.rawValue && currentState == GumletPlayerStateMachine.GumletPlayerStateViewinit.rawValue && destinationState == GumletPlayerStateMachine.GumletPlayerStateViewinit.rawValue)
        {
            return true
        }
        
        else if (eventName == Events.isPlayerReady.rawValue && currentState == GumletPlayerStateMachine.GumletPlayerStateViewinit.rawValue && destinationState == GumletPlayerStateMachine.GumletPlayerStateReady.rawValue)
        {
            return true
        }
        
        else if (eventName == Events.isPlayerReady.rawValue && currentState == GumletPlayerStateMachine.GumletPlayerStateError.rawValue && destinationState == GumletPlayerStateMachine.GumletPlayerStateReady.rawValue)
        {
            return true
        }
        else if (eventName == Events.isPlay.rawValue && currentState == GumletPlayerStateMachine.GumletPlayerStateReady.rawValue && destinationState == GumletPlayerStateMachine.GumletPlayerStatePlay.rawValue)
        {
            return true
        }
        else if (eventName == Events.isPlay.rawValue && currentState == GumletPlayerStateMachine.GumletPlayerStatePaused.rawValue && destinationState == GumletPlayerStateMachine.GumletPlayerStatePlay.rawValue)
        {
            return true
        }
        
        else if (eventName == Events.isPlay.rawValue && currentState == GumletPlayerStateMachine.GumletPlayerStateBuffering.rawValue && destinationState == GumletPlayerStateMachine.GumletPlayerStatePlay.rawValue)
        {
            return true
        }
        
        else if (eventName == Events.isPlaying.rawValue && currentState == GumletPlayerStateMachine.GumletPlayerStatePlay.rawValue && destinationState == GumletPlayerStateMachine.GumletPlayerStatePlaying.rawValue)
        {
            return true
        }
        else if (eventName == Events.isPlaying.rawValue && currentState == GumletPlayerStateMachine.GumletPlayerStateBuffering.rawValue && destinationState == GumletPlayerStateMachine.GumletPlayerStatePlaying.rawValue)
        {
            return true
        }
        else if (eventName == Events.isEventError.rawValue && currentState == GumletPlayerStateMachine.GumletPlayerStateBuffering.rawValue && destinationState == GumletPlayerStateMachine.GumletPlayerStateError.rawValue)
        {
            return true
        }
        else if (eventName == Events.isEventError.rawValue && currentState == GumletPlayerStateMachine.GumletPlayerStateViewinit.rawValue && destinationState == GumletPlayerStateMachine.GumletPlayerStateError.rawValue)
        {
            return true
        }
        else if (eventName == Events.isEventError.rawValue && currentState == GumletPlayerStateMachine.GumletPlayerStateReady.rawValue && destinationState == GumletPlayerStateMachine.GumletPlayerStateError.rawValue)
        {
            return true
        }
        
        else if (eventName == Events.isEventError.rawValue && currentState == GumletPlayerStateMachine.GumletPlayerStatePlaying.rawValue && destinationState == GumletPlayerStateMachine.GumletPlayerStateError.rawValue)
        {
            return true
        }
        
        else if (eventName == Events.isEventError.rawValue && currentState == GumletPlayerStateMachine.GumletPlayerStatePlay.rawValue && destinationState == GumletPlayerStateMachine.GumletPlayerStateError.rawValue)
        {
            return true
        }
        
        else if (eventName == Events.isEventError.rawValue && currentState == GumletPlayerStateMachine.GumletPlayerStatePaused.rawValue && destinationState == GumletPlayerStateMachine.GumletPlayerStateError.rawValue)
        {
            return true
        }

        else if (eventName == Events.isEventError.rawValue && currentState == GumletPlayerStateMachine.GumletPlayerStateSeek.rawValue && destinationState == GumletPlayerStateMachine.GumletPlayerStateError.rawValue)
        {
            return true
        }

        
        else if (eventName == Events.isEventError.rawValue && currentState == GumletPlayerStateMachine.GumletPlayerStateViewEnd.rawValue && destinationState == GumletPlayerStateMachine.GumletPlayerStateError.rawValue)
        {
            return true
        }

        else if (eventName == Events.isBufferingStart.rawValue && currentState == GumletPlayerStateMachine.GumletPlayerStatePlaying.rawValue && destinationState == GumletPlayerStateMachine.GumletPlayerStateBuffering.rawValue)
        {
            return true
        }
        else if (eventName == Events.isBufferingStart.rawValue && currentState == GumletPlayerStateMachine.GumletPlayerStatePlay.rawValue && destinationState == GumletPlayerStateMachine.GumletPlayerStateBuffering.rawValue)
        {
            return true
        }
        else if (eventName == Events.isBufferingStart.rawValue && currentState == GumletPlayerStateMachine.GumletPlayerStateBuffering.rawValue && destinationState == GumletPlayerStateMachine.GumletPlayerStateBuffering.rawValue)
        {
            return true
        }
        else if (eventName == Events.isBufferingStart.rawValue || currentState == GumletPlayerStateMachine.GumletPlayerStatePaused.rawValue && destinationState == GumletPlayerStateMachine.GumletPlayerStateBuffering.rawValue)
        {
            return true
        }
        else if (eventName == Events.isBufferingEnd.rawValue && currentState == GumletPlayerStateMachine.GumletPlayerStatePlaying.rawValue && destinationState == GumletPlayerStateMachine.GumletPlayerStateBuffering.rawValue)
        {
            return true
        }
        else if (eventName == Events.isBufferingEnd.rawValue && currentState == GumletPlayerStateMachine.GumletPlayerStatePaused.rawValue && destinationState == GumletPlayerStateMachine.GumletPlayerStateBuffering.rawValue)
        {
            return true
        }
        else if (eventName == Events.isBufferingEnd.rawValue && currentState == GumletPlayerStateMachine.GumletPlayerStatePlay.rawValue && destinationState == GumletPlayerStateMachine.GumletPlayerStateBuffering.rawValue)
        {
            return true
        }
        else if (eventName == Events.isBufferingEnd.rawValue && currentState == GumletPlayerStateMachine.GumletPlayerStateBuffering.rawValue && destinationState == GumletPlayerStateMachine.GumletPlayerStateBuffering.rawValue)
        {
            return true
        }
        else if (eventName == Events.isMute.rawValue && currentState == GumletPlayerStateMachine.GumletPlayerStatePlaying.rawValue && destinationState == GumletPlayerStateMachine.GumletPlayerStatePlaying.rawValue)
        {
            return true
        }
        else if (eventName == Events.isMute.rawValue && currentState == GumletPlayerStateMachine.GumletPlayerStatePaused.rawValue && destinationState == GumletPlayerStateMachine.GumletPlayerStatePaused.rawValue)
        {
            return true
        }
        else if (eventName == Events.isUnMute.rawValue && currentState == GumletPlayerStateMachine.GumletPlayerStatePaused.rawValue && destinationState == GumletPlayerStateMachine.GumletPlayerStatePaused.rawValue)
        {
            return true
        }
        else if (eventName == Events.isUnMute.rawValue && currentState == GumletPlayerStateMachine.GumletPlayerStatePlaying.rawValue && destinationState == GumletPlayerStateMachine.GumletPlayerStatePlaying.rawValue)
        {
            return true
        }
        else if (eventName == Events.isSeek.rawValue && currentState == GumletPlayerStateMachine.GumletPlayerStatePlaying.rawValue && destinationState == GumletPlayerStateMachine.GumletPlayerStateSeek.rawValue)
        {
            return true
        }
        
        else if (eventName == Events.isSeek.rawValue || currentState == GumletPlayerStateMachine.GumletPlayerStatePaused.rawValue && destinationState == GumletPlayerStateMachine.GumletPlayerStateSeek.rawValue)
        {
            return true
        }
        else if (eventName == Events.isSeek.rawValue || currentState == GumletPlayerStateMachine.GumletPlayerStatePlay.rawValue && destinationState == GumletPlayerStateMachine.GumletPlayerStateSeek.rawValue)
        {
            return true
        }
        else if (eventName == Events.isSeek.rawValue || currentState == GumletPlayerStateMachine.GumletPlayerStateBuffering.rawValue && destinationState == GumletPlayerStateMachine.GumletPlayerStateSeek.rawValue)
        {
            return true
        }

        
        else if (eventName == Events.isPaused.rawValue && currentState == GumletPlayerStateMachine.GumletPlayerStatePlaying.rawValue && destinationState == GumletPlayerStateMachine.GumletPlayerStatePaused.rawValue)
        {
            return true
        }

        else if (eventName == Events.isPaused.rawValue && currentState == GumletPlayerStateMachine.GumletPlayerStatePlay.rawValue && destinationState == GumletPlayerStateMachine.GumletPlayerStatePaused.rawValue)
        {
            return true
        }
        
        else if (eventName == Events.isDeviceOrientationChange.rawValue && currentState == GumletPlayerStateMachine.GumletPlayerStatePaused.rawValue && destinationState == GumletPlayerStateMachine.GumletPlayerStatePaused.rawValue)
        {
            return true
        }
        
        else if (eventName == Events.isDeviceOrientationChange.rawValue && currentState == GumletPlayerStateMachine.GumletPlayerStatePlaying.rawValue && destinationState == GumletPlayerStateMachine.GumletPlayerStatePlaying.rawValue)
        {
            return true
        }
        
        else if (eventName == Events.isDeviceOrientationChange.rawValue && currentState == GumletPlayerStateMachine.GumletPlayerStateReady.rawValue && destinationState == GumletPlayerStateMachine.GumletPlayerStateReady.rawValue)
        {
            return true
        }
        
        else if (eventName == Events.isDeviceOrientationChange.rawValue && currentState == GumletPlayerStateMachine.GumletPlayerStatePlay.rawValue && destinationState == GumletPlayerStateMachine.GumletPlayerStatePlay.rawValue)
        {
            return true
        }
        
        else if (eventName == Events.isVideochange.rawValue && currentState == GumletPlayerStateMachine.GumletPlayerStateViewinit.rawValue && destinationState == GumletPlayerStateMachine.GumletPlayerStateViewinit.rawValue)
        {
            return true
        }
        
        
        else if (eventName == Events.isQualityChange.rawValue && currentState == GumletPlayerStateMachine.GumletPlayerStatePlaying.rawValue && destinationState == GumletPlayerStateMachine.GumletPlayerStatePlaying.rawValue)
        {
            return true
        }
        
        else if (eventName == Events.isEnd.rawValue && currentState == GumletPlayerStateMachine.GumletPlayerStatePlaying.rawValue && destinationState == GumletPlayerStateMachine.GumletPlayerStateViewEnd.rawValue)
        {
            return true
        }
        
        else if (eventName == Events.isEnd.rawValue && currentState == GumletPlayerStateMachine.GumletPlayerStateBuffering.rawValue && destinationState == GumletPlayerStateMachine.GumletPlayerStateViewEnd.rawValue)
        {
            return true
        }
        
        else if (eventName == Events.isEnd.rawValue && currentState == GumletPlayerStateMachine.GumletPlayerStatePaused.rawValue && destinationState == GumletPlayerStateMachine.GumletPlayerStateViewEnd.rawValue)
        {
            return true
        }
        else
        {
            return false
        }
    }
}



//
//  GumletTransition.swift
//  GumletSDKVidAnalytics
//
//  Created by Nishant Pandey on 15/11/21.
//

import Foundation

 class GumletTransition {
  
    var states: String = ""

    init(states: String) {
        self.states = states

    }

     func transitionState(destinationState:String) -> String {
        let performTransition = getPlayerState(destinationState: destinationState)
//        var states: String = ""
        if performTransition {
            print("[StateMachine] Transitioning from state \(self.states) to \(destinationState)")
            states = destinationState
        }
        print("statesTranstioin:\(states)")
        return states
    }
    
    
    
    func getPlayerState(destinationState:String) -> Bool {
        
        print("destinationState:\(destinationState)")
       switch (destinationState) {
            
       case GumletPlayerStateMachine.GumletPlayerStateViewinit.rawValue:
            return true
        
       case GumletPlayerStateMachine.GumletPlayerStateReady.rawValue:
            return true
        
       case GumletPlayerStateMachine.GumletPlayerStateBuffering.rawValue, GumletPlayerStateMachine.GumletPlayerStatePlay.rawValue :
            return true
        
       case GumletPlayerStateMachine.GumletPlayerStatePlay.rawValue:
            return true
        
//       case GumletPlayerStateMachine.GumletPlayerStateBuffering.rawValue:
//        return true
        
       case GumletPlayerStateMachine.GumletPlayerStatePlaying.rawValue, GumletPlayerStateMachine.GumletPlayerStateBuffering.rawValue:
            return true
        
       case GumletPlayerStateMachine.GumletPlayerStateSeek.rawValue:
            return true
        
       case GumletPlayerStateMachine.GumletPlayerStatePlaying.rawValue, GumletPlayerStateMachine.GumletPlayerStateSeek.rawValue:
            return true
        
       case GumletPlayerStateMachine.GumletPlayerStateMute.rawValue:
        return true
        
       case GumletPlayerStateMachine.GumletPlayerStatePlaying.rawValue, GumletPlayerStateMachine.GumletPlayerStateMute.rawValue:
        return true
        
       case GumletPlayerStateMachine.GumletPlayerStateUnMute.rawValue:
        return true
        
       case GumletPlayerStateMachine.GumletPlayerStatePlaying.rawValue, GumletPlayerStateMachine.GumletPlayerStateUnMute.rawValue:
        return true
        
       case GumletPlayerStateMachine.GumletPlayerStatePaused.rawValue:
            return true
        
       case GumletPlayerStateMachine.GumletPlayerStatePaused.rawValue, GumletPlayerStateMachine.GumletPlayerStateUnMute.rawValue:
        return true
        
       case GumletPlayerStateMachine.GumletPlayerStatePaused.rawValue, GumletPlayerStateMachine.GumletPlayerStateMute.rawValue:
        return true
       
       case GumletPlayerStateMachine.GumletPlayerStateViewEnd.rawValue:
          return true
        
       case GumletPlayerStateMachine.GumletPlayerStateError.rawValue:
               return true
           
       default:
          return true
       }
   }
}



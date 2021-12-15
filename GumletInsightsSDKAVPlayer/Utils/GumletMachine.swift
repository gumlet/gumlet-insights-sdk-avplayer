//
//  GumletMachine.swift
//  GumletSDKVidAnalytics
//
//  Created by Nishant Pandey on 15/11/21.
//

import Foundation


 
    enum GumletPlayerStateMachine : String
    {
        case GumletPlayerStateViewinit = "Player_Setup"
        case GumletPlayerStateReady = "Ready"
        case GumletPlayerStatePlay = "Play"
        case GumletPlayerStateMute = "Mute"
        case GumletPlayerStateUnMute = "UnMute"
        case GumletPlayerStateSeek = "Seek"
        case GumletPlayerStateBuffering = "Buffering"
        case GumletPlayerStatePlaying = "Playing"
        case GumletPlayerStatePaused = "Paused"
        case GumletPlayerStateError = "Error"
        case GumletPlayerStateViewEnd = "End"
    }
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







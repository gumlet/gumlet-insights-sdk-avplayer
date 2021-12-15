//
//  Constants.swift
//  GumletVideoAnalyticsSDK
//
//  
//

import Foundation
struct Constants {
    struct API {
        static let BaseURL = "http://video-analytics-ingest-dev.gumlet.com"
        static let event_family = ["session", "player_init","session_event","network_request"]
        static let gumletSDK_version = "1.0.0"
        static let playerSoftware =  "AVPlayer"
        static let isPreload = "true"
    }
}


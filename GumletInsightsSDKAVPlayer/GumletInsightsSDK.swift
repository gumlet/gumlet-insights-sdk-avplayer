//
//  GumletVideoAnalyticsSDK.swift
//  GumletVideoAnalyticsSDK
//
//
//

import Foundation
import WebKit
import AVKit

public class GumletInsightsSDK {
    
    private static var environmentKey: String = ""
    private static var player: AVPlayer? = nil
    private static var userData: GumletInsightsUserData? = nil
    
    private static var customVideoData: GumletInsightsCustomVideoData? = nil
    private static var customPlayerData: GumletInsightsCustomPlayerData? = nil
    private static var customData:GumletInsightsCustomData? = nil
    
    private static var gumletInsightsManager = GumletInsightsManager()
    
    private static let core = AVPlayerCore()
    public static func version() -> String {
        return "AVPlayer_1.0.0"
    }
    
    public static func browser_version() -> String {
        return "AVPlayer_1.0.0"
    }
    
    
    public class func initAVPlayerViewController(_ playerViewController:AVPlayerViewController, userData:GumletInsightsUserData? = nil, customData:GumletInsightsCustomData? = nil,customVideoData:GumletInsightsCustomVideoData? = nil,customPlayerData:GumletInsightsCustomPlayerData? = nil,  config: GumletInsightsConfig) {
        
        gumletInsightsManager.verifyPropertyId(propertyId: config.proprtyId, completion: {(isValidated) in
            if isValidated {
                self.environmentKey = config.proprtyId
                self.player = playerViewController.player
                self.userData = userData
                self.customPlayerData = customPlayerData
                UserDefaults.standard.setValue(self.environmentKey, forKey: "environmentKey")
                //self.customData =
                //        playerViewController.addObserver(core, forKeyPath: #keyPath(AVPlayerViewController.videoBounds), options: [.old, .new], context: nil)
                //        DispatchQueue.global(qos: .utility).async {
                core.setupPlayer(playerAV: self.player!, propertyId: self.environmentKey,userData: self.userData!, customerPlayerData: self.customPlayerData!)
                //        }
            }
            else {
                print("Error!! -- PropertyId '\(config.proprtyId)' is not validated. Get new Property Id from dashboard.")
            }
    }
    
    public class func updateDataAVPlayerViewController(_ playerViewController:AVPlayerViewController, userData:GumletInsightsUserData? = nil, customData:GumletInsightsCustomData? = nil,customVideoData:GumletInsightsCustomVideoData? = nil,customPlayerData:GumletInsightsCustomPlayerData? = nil ) {
            gumletInsightsManager.verifyPropertyId(propertyId: config.proprtyId, completion: {(isValidated) in
                if isValidated {
                    self.environmentKey = UserDefaults.standard.value(forKey:"environmentKey") as! String
                    self.player = playerViewController.player
                    self.userData = userData
                    self.customPlayerData = customPlayerData
                    core.setupPlayer(playerAV: self.player!, propertyId: self.environmentKey,userData: self.userData!, customerPlayerData: self.customPlayerData!)
                }
                else {
                    print("Error!! -- PropertyId '\(config.proprtyId)' is not validated. Get new Property Id from dashboard.")
                }
       
    }
    
    public class func initAVPlayerLayer(_ playerLayer:AVPlayerLayer, userData:GumletInsightsUserData? = nil, customData:GumletInsightsCustomData? = nil,customVideoData:GumletInsightsCustomPlayerData? = nil, config: GumletInsightsConfig) {
            gumletInsightsManager.verifyPropertyId(propertyId: config.proprtyId, completion: {(isValidated) in
                if isValidated {
                    self.environmentKey = config.proprtyId
                    self.player = playerLayer.player
                    self.userData = userData
                    self.customData = customData
                    //        DispatchQueue.global(qos: .utility).async {
                    core.setupPlayer(playerAV: self.player!, propertyId: self.environmentKey,userData: self.userData!, customerPlayerData: self.customPlayerData!)
                    //        }
                }
                else {
                    print("Error!! -- PropertyId '\(config.proprtyId)' is not validated. Get new Property Id from dashboard.")
                }
    }
    
    
    public class func updateDataAVPlayerLayer(_ playerLayer:AVPlayerLayer, userData:GumletInsightsUserData? = nil, customData:GumletInsightsCustomData? = nil,customVideoData:GumletInsightsCustomVideoData? = nil,customPlayerData:GumletInsightsCustomPlayerData? = nil ) {
            gumletInsightsManager.verifyPropertyId(propertyId: config.proprtyId, completion: {(isValidated) in
                if isValidated {
                    self.environmentKey = UserDefaults.standard.value(forKey:"environmentKey") as! String
                    self.player = playerLayer.player
                    self.userData = userData
                    self.customPlayerData = customPlayerData
                    self.customData = customData
                    
                    
                    //        playerViewController.addObserver(core, forKeyPath: #keyPath(AVPlayerViewController.videoBounds), options: [.old, .new], context: nil)
                    //        DispatchQueue.global(qos: .utility).async {
                    core.setupPlayer(playerAV: self.player!, propertyId: self.environmentKey,userData: self.userData!, customerPlayerData: self.customPlayerData!)
                    //        }
                }
                else {
                    print("Error!! -- PropertyId '\(config.proprtyId)' is not validated. Get new Property Id from dashboard.")
                }
    }
    
    
    
    
    public class func userPersonalData() -> [String:Any]?{
        if let userData = userData{
            return ["user_name":userData.userName,
                    "user_email":userData.userEmail,
                    "user_phone":userData.userPhone,
                    "user_profile_image":userData.userProfileImage,
                    "user_address_line1":userData.userAddressLine1,
                    "user_address_line2":userData.userAddressLine2,
                    "user_city":userData.userCity,
                    "user_state":userData.userState,
                    "user_country":userData.userCountry,
                    "user_zipcode":userData.userZipcode
            ]
        }
        return nil
    }
    
    public class func getCustomData() -> [String:Any]?{
        if let customData = customData{
            return [ "custom_user_id":customData.customUserId,
                     "custom_data_1":customData.customData1,
                     "custom_data_2":customData.customData2,
                     "custom_data_3":customData.customData3,
                     "custom_data_4":customData.customData4,
                     "custom_data_5":customData.customData5,
                     "custom_data_6":customData.customData6,
                     "custom_data_7":customData.customData7,
                     "custom_data_8":customData.customData8,
                     "custom_data_9":customData.customData9,
                     "custom_data_10":customData.customData10
            ]
        }
        return nil
    }
    /*&player_software=\(playerSoftware)&player_name=\(playerName)&player_integration_version=\(playerIntegrationVersion)**/
    
    public class func getCustomPlayerData() -> [String:Any]?{
        if let playerData = customPlayerData{
            return [ "player_name":playerData.GumletPlayerName,
                     "player_integration_version":playerData.GumletPlayerIntegrationVersion,
                     "meta_page_type":playerData.gumletPageType
            ]
        }
        return nil
    }
    
    public class func getCustomVideoData() -> [String:Any]?{
        if let customVideoData = customVideoData{
            return [ "custom_content_type":customVideoData.customContentType,
                     "custom_video_duration_millis":customVideoData.customVideoDurationMillis,
                     "custom_encoding_variant":customVideoData.customEncodingVariant,
                     "custom_video_language":customVideoData.customVideoLanguage,
                     "custom_video_id":customVideoData.customVideoId,
                     "custom_video_series":customVideoData.customVideoSeries,
                     "customVideoProducer":customVideoData.customVideoProducer,
                     "customVideotitle":customVideoData.customVideotitle,
                     "customVideoVariantName":customVideoData.customVideoVariantName,
                     "customVideoVariant":customVideoData.customVideoVariant
            ]
        }
        return nil
    }
    
    
}



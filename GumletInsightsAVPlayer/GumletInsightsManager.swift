//
//  VideoAnalyticsManager.swift
//  GumletVideoAnalytics
//
//
//

import Foundation
import WebKit

struct GumletInsightsManager {
    
    
    // MARK:- constants
    
    
    let event_family = ["session","session_event", "player_init","network_request"]
    
    //    let gumletEnvironment_Key = "gHkjn8r"
    let gumletSDK_version = "1.0.0"
    let video_base_url = "https://video-analytics-ingest.gumlet.com?" //"http://video-analytics-ingest.gumlet.com?"
    
    
    
    
    
    
    
    //MARK:--get device information
    func getUserAgent() -> String{
        
        var darwinid:String = ""
        let appName =  Bundle.main.object(forInfoDictionaryKey: kCFBundleNameKey as String) as? String
        
        let platform = UIDevice.current.systemName
        let modelID = UIDevice().type
        
        let operationSystemVersion = ProcessInfo.processInfo.operatingSystemVersionString
        let bundle = Bundle(identifier: "com.apple.CFNetwork")
        let versionAny = bundle?.infoDictionary?[kCFBundleVersionKey as String]
        let CFversion = versionAny as? String
        
        var systemInfo = utsname()
        uname(&systemInfo)
        let machineMirror = Mirror(reflecting: systemInfo.release)
        _ = machineMirror.children.reduce("") { identifier, element in
            guard let value = element.value as? Int8,
                  value != 0 else {
                return identifier
            }
            
            darwinid = identifier + String(UnicodeScalar(UInt8(value)))
            return darwinid
        }
        
        let userAgent = ("\(String(describing: appName!)),\(platform),\(modelID),\(operationSystemVersion),CFNetwork/ \(CFversion!),Darvin/\(darwinid)")
        return userAgent
    }
    
    
    //MARK:- Session Api call
    func callSessionAPI(sessionId:String, userId:String, metaDeviceArch:String,userName:String, userEmail:String, userCity:String,userPhone:String,userAddLineOne:String,userAddLineTwo:String,userState:String,userZipCode:String,userCountry:String,gumletEnvironmentKey:String, version:String, platform:String, deviceCategory:String, deviceManufacturer:String, deviceName:String,deviceWidth:Int,deviceDisplayPPI:Float, deviceHeight:Int, deviceIsTouchable:Bool, localCurrentTime:String,orientation:String,customUserId:String)
    {
        let modelID = UIDevice().type
        let bundleId = Bundle.main.bundleIdentifier!
        let browser_version = 1.0//meta_device_architecture meta_device_manufacturer
        let customer_data1 = "data_1"
        
        let originalString = "\(video_base_url)&event_family=\(event_family[0])&session_id=\(sessionId)&property_id=\(gumletEnvironmentKey)&user_id=\(userId)&viewer_client_version=\(gumletSDK_version)&meta_device_architecture=\(metaDeviceArch)&user_name=\(userName)&user_email=\(userEmail)&user_city=\(userCity)&meta_operating_system_version=\(version)&meta_operating_system=\(platform)&meta_device_category=\(deviceCategory)&meta_device_manufacturer=\(deviceManufacturer)&meta_device_name=\(modelID)&meta_device_display_width=\(Float(deviceWidth))&meta_device_display_height=\(Float(deviceHeight))&meta_device_display_dpr=\(Float(deviceDisplayPPI))&meta_device_is_touchscreen=\(deviceIsTouchable)&meta_browser=\(bundleId)&meta_browser_version=\(browser_version)&z=\(localCurrentTime)&orientation=\(orientation)&user_phone=\(userPhone)&user_address_line1=\(userAddLineOne)&user_address_line2=\(userAddLineTwo)&user_state=\(userState)&user_country=\(userCountry)&user_zipcode=\(userZipCode)&custom_user_id=\(customUserId)&custom_data_1=\(customer_data1)&custom_data_2=\("data_2")&custom_data_3=\("data_3")&custom_data_4=\("data_4")&custom_data_5=\("data_5")&custom_data_6=\("data_6")&custom_data_7=\("data_7")&custom_data_8=\("data_8")&custom_data_9=\("data_9")&custom_data_10=\("data_10")"
        //&user_profile_image=\()
        
        let urlString = originalString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
        
        performRequest(urlString:urlString!)
        
    }
    
    //MARK:- Player Api call
    func callPlayerAPI(sessionId:String, userId:String, playerInstaceId:String, playerHeight:Int, playerWidth:Int, pageType:String, pageUrl:String, playerSoftware:String, playerLanguageCode:String, playerName:String, playerIntegrationVersion:String, playerSoftwareVersion:String, playerPreload:String, gumletEnvironmentKey:String,localCurrentTime:String,orientation:String,customUserId:String)
    {
        let originalString = "\(video_base_url)&event_family=\(event_family[2])&player_instance_id=\(playerInstaceId)&property_id=\(gumletEnvironmentKey)&session_id=\(sessionId)&user_id=\(userId)&meta_page_type=\(pageType)&meta_page_url=\(pageUrl)&player_software=\(playerSoftware)&player_name=\(playerName)&player_integration_version=\(playerIntegrationVersion)&player_preload=\(playerPreload)&player_height_pixels=\(playerHeight)&player_width_pixels=\(playerWidth)&player_language_code=\(playerLanguageCode)&z=\(localCurrentTime)&orientation=\(orientation)&custom_user_id=\(customUserId)&custom_data_1=\("data1")&custom_data_2=\("data_2")&custom_data_3=\("data_3")&custom_data_4=\("data_4")&custom_data_5=\("data_5")&custom_data_6=\("data_6")&custom_data_7=\("data_7")&custom_data_8=\("data_8")&custom_data_9=\("data_9")&custom_data_10=\("data_10")"
        
        
        let urlString = originalString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
        
        performRequest(urlString:urlString!)
    }
    
    
    //MARK:- Event Api call
    
    func callEventAPI(eventId:String, sessionId:String, userId:String, playbackId:String, playerInstaceId:String, event:String, startPlayTimeInMS:Double, videoDownScale:Float, videoUpscale:Float, bitrateMbps:Float, playerRemotePlayed:String, videoSourceDomain:String, videoTotalDuration:Double, videoWidthPixel:Float, videoHeightPixel:Float, videoSourceUrl:String, videoSourceHostName:String, videoSourceType:String, muted:Bool, previousEvent:String, previousEventTime:Float, gumletEnvironmentKey:String,localCurrentTime:String,orientation:String,orientation_from:String,fullscreen:Bool,quality:String,errorMsg:String,errorTitle:String, errorCode:Int)
    {
        let muteProp = muted
        var originalString :String = ""
        //        let videoQualityChange = quality
        
        
        if (muteProp == false)
        {
            if quality == "true"
            {
                originalString = "\(video_base_url)&event_family=\(event_family[1])&event_id=\(eventId)&session_id=\(sessionId)&property_id=\(gumletEnvironmentKey)&user_id=\(userId)&playback_id=\(playbackId)&player_instance_id=\(playerInstaceId)&event=\(event)&playback_time_instant_millis=\(startPlayTimeInMS)&player_remote_played=\(playerRemotePlayed)&video_total_duration_millis=\(videoTotalDuration)&video_source_url=\(videoSourceUrl)&video_source_hostname=\(videoSourceHostName)&video_source_format=\(videoSourceType)&previous_event=\(previousEvent)&millis_from_previous_event=\(previousEventTime)&video_width_pixels=\(videoWidthPixel)&video_height_pixels=\(videoHeightPixel)&bitrate_mbps=\(bitrateMbps)&z=\(localCurrentTime)&orientation=\(orientation)&orientation_from=\(orientation_from)&fullscreen=\(fullscreen)&video_downscale_percentage=\(videoDownScale)&video_upscale_percentage=\(videoUpscale)&custom_content_type=\("xyz")&custom_video_duration_millis=\("134598")&custom_encoding_variant=\("abc")&custom_video_language=\("Hindi")&custom_video_id=\("qwdr32efcSA")&custom_video_series=\("1A")&custom_video_producer=\("khush")&custom_video_title=\("Animated")&custom_video_variant_name=\("alot")&custom_video_variant=\("super")&custom_data_1=\("data1")&custom_data_2=\("data_2")&custom_data_3=\("data_3")&custom_data_4=\("data_4")&custom_data_5=\("data_5")&custom_data_6=\("data_6")&custom_data_7=\("data_7")&custom_data_8=\("data_8")&custom_data_9=\("data_9")&custom_data_10=\("data_10")&error=\(errorTitle)&error_code=\(errorCode)&error_text=\(errorMsg)&quality=\(quality)"
                
                
            }
            else
            {
                
                
                originalString = "\(video_base_url)&event_family=\(event_family[1])&event_id=\(eventId)&session_id=\(sessionId)&property_id=\(gumletEnvironmentKey)&user_id=\(userId)&playback_id=\(playbackId)&player_instance_id=\(playerInstaceId)&event=\(event)&playback_time_instant_millis=\(startPlayTimeInMS)&player_remote_played=\(playerRemotePlayed)&video_total_duration_millis=\(videoTotalDuration)&video_source_url=\(videoSourceUrl)&video_source_hostname=\(videoSourceHostName)&video_source_format=\(videoSourceType)&previous_event=\(previousEvent)&millis_from_previous_event=\(previousEventTime)&video_width_pixels=\(videoWidthPixel)&video_height_pixels=\(videoHeightPixel)&bitrate_mbps=\(bitrateMbps)&z=\(localCurrentTime)&orientation=\(orientation)&orientation_from=\(orientation_from)&fullscreen=\(fullscreen)&video_downscale_percentage=\(videoDownScale)&video_upscale_percentage=\(videoUpscale)&custom_content_type=\("xyz")&custom_video_duration_millis=\("134598")&custom_encoding_variant=\("abc")&custom_video_language=\("Hindi")&custom_video_id=\("qwdr32efcSA")&custom_video_series=\("1A")&custom_video_producer=\("khush")&custom_video_title=\("Animated")&custom_video_variant_name=\("alot")&custom_video_variant=\("super")&custom_data_1=\("data1")&custom_data_2=\("data_2")&custom_data_3=\("data_3")&custom_data_4=\("data_4")&custom_data_5=\("data_5")&custom_data_6=\("data_6")&custom_data_7=\("data_7")&custom_data_8=\("data_8")&custom_data_9=\("data_9")&custom_data_10=\("data_10")&error=\(errorTitle)&error_code=\(errorCode)&error_text=\(errorMsg)"
                
                
            }
        }
        else if (muteProp == true)
        {
            if quality == "true"
            {
                originalString = "\(video_base_url)&event_family=\(event_family[1])&event_id=\(eventId)&session_id=\(sessionId)&property_id=\(gumletEnvironmentKey)&user_id=\(userId)&playback_id=\(playbackId)&player_instance_id=\(playerInstaceId)&event=\(event)&playback_time_instant_millis=\(startPlayTimeInMS)&player_remote_played=\(playerRemotePlayed)&video_total_duration_millis=\(videoTotalDuration)&video_source_url=\(videoSourceUrl)&video_source_hostname=\(videoSourceHostName)&video_source_format=\(videoSourceType)&muted=\(muted)&previous_event=\(previousEvent)&millis_from_previous_event=\(previousEventTime)&video_width_pixels=\(videoWidthPixel)&video_height_pixels=\(videoHeightPixel)&bitrate_mbps=\(bitrateMbps)&z=\(localCurrentTime)&orientation=\(orientation)&orientation_from=\(orientation_from)&fullscreen=\(fullscreen)&video_downscale_percentage=\(videoDownScale)&video_upscale_percentage=\(videoUpscale)&custom_content_type=\("xyz")&custom_video_duration_millis=\("134598")&custom_encoding_variant=\("abc")&custom_video_language=\("Hindi")&custom_video_id=\("qwdr32efcSA")&custom_video_series=\("1A")&custom_video_producer=\("khush")&custom_video_title=\("Animated")&custom_video_variant_name=\("alot")&custom_video_variant=\("super")&custom_data_1=\("customer_data1")&custom_data_2=\("data_2")&custom_data_3=\("data_3")&custom_data_4=\("data_4")&custom_data_5=\("data_5")&custom_data_6=\("data_6")&custom_data_7=\("data_7")&custom_data_8=\("data_8")&custom_data_9=\("data_9")&custom_data_10=\("data_10")&error=\(errorTitle)&error_code=\(errorCode)&error_text=\(errorMsg)&quality=\(quality)"
                
                
            }
            
            originalString = "\(video_base_url)&event_family=\(event_family[1])&event_id=\(eventId)&session_id=\(sessionId)&property_id=\(gumletEnvironmentKey)&user_id=\(userId)&playback_id=\(playbackId)&player_instance_id=\(playerInstaceId)&event=\(event)&playback_time_instant_millis=\(startPlayTimeInMS)&player_remote_played=\(playerRemotePlayed)&video_total_duration_millis=\(videoTotalDuration)&video_source_url=\(videoSourceUrl)&video_source_hostname=\(videoSourceHostName)&video_source_format=\(videoSourceType)&muted=\(muted)&previous_event=\(previousEvent)&millis_from_previous_event=\(previousEventTime)&video_width_pixels=\(videoWidthPixel)&video_height_pixels=\(videoHeightPixel)&bitrate_mbps=\(bitrateMbps)&z=\(localCurrentTime)&orientation=\(orientation)&orientation_from=\(orientation_from)&fullscreen=\(fullscreen)&video_downscale_percentage=\(videoDownScale)&video_upscale_percentage=\(videoUpscale)&custom_content_type=\("xyz")&custom_video_duration_millis=\("134598")&custom_encoding_variant=\("abc")&custom_video_language=\("Hindi")&custom_video_id=\("qwdr32efcSA")&custom_video_series=\("1A")&custom_video_producer=\("khush")&custom_video_title=\("Animated")&custom_video_variant_name=\("alot")&custom_video_variant=\("super")&custom_data_1=\("customer_data1")&custom_data_2=\("data_2")&custom_data_3=\("data_3")&custom_data_4=\("data_4")&custom_data_5=\("data_5")&custom_data_6=\("data_6")&custom_data_7=\("data_7")&custom_data_8=\("data_8")&custom_data_9=\("data_9")&custom_data_10=\("data_10")&error=\(errorTitle)&error_code=\(errorCode)&error_text=\(errorMsg)"
            
            
            
        }
        
        
        
        
        let urlString = originalString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
        
        
        performRequest(urlString:urlString!)
    }
    
    
    
    func callSeekEventAPI(eventId:String, sessionId:String, userId:String, playbackId:String, playerInstaceId:String, event:String,seekingtime:Double, seekedTime:Double, startPlayTimeInMS:Double, videoDownScale:Float, videoUpscale:Float, bitrateMbps:Float, playerRemotePlayed:String, videoSourceDomain:String, videoTotalDuration:Double, videoWidthPixel:Float, videoHeightPixel:Float, videoSourceUrl:String, videoSourceHostName:String, videoSourceType:String, muted:Bool, previousEvent:String, previousEventTime:Float, gumletEnvironmentKey:String,localCurrentTime:String,orientation:String,orientation_from:String,fullscreen:Bool,quality:String)
    {
        let muteProp = muted
        var originalString :String = ""
        
        
        
        if (muteProp == false)
        {
            
            
            originalString = "\(video_base_url)&event_family=\(event_family[1])&event_id=\(eventId)&session_id=\(sessionId)&property_id=\(gumletEnvironmentKey)&user_id=\(userId)&playback_id=\(playbackId)&player_instance_id=\(playerInstaceId)&event=\(event)&from=\(seekingtime)&to=\(seekedTime)&playback_time_instant_millis=\(startPlayTimeInMS)&player_remote_played=\(playerRemotePlayed)&video_total_duration_millis=\(videoTotalDuration)&video_source_url=\(videoSourceUrl)&video_source_hostname=\(videoSourceHostName)&video_source_format=\(videoSourceType)&previous_event=\(previousEvent)&millis_from_previous_event=\(previousEventTime)&video_width_pixels=\(videoWidthPixel)&video_height_pixels=\(videoHeightPixel)&bitrate_mbps=\(bitrateMbps)&z=\(localCurrentTime)&orientation=\(orientation)&orientation_from=\(orientation_from)&fullscreen=\(fullscreen)&video_downscale_percentage=\(videoDownScale)&video_upscale_percentage=\(videoUpscale)&custom_content_type=\("xyz")&custom_video_duration_millis=\("134598")&custom_encoding_variant=\("abc")&custom_video_language=\("Hindi")&custom_video_id=\("qwdr32efcSA")&custom_video_series=\("1A")&customVideoProducer=\("khush")&customVideotitle=\("Animated")&customVideoVariantName=\("alot")&customVideoVariant=\("super")&custom_data_1=\("data_1")&custom_data_2=\("data_2")&custom_data_3=\("data_3")&custom_data_4=\("data_4")&custom_data_5=\("data_5")&custom_data_6=\("data_6")&custom_data_7=\("data_7")&custom_data_8=\("data_8")&custom_data_9=\("data_9")&custom_data_10=\("data_10")"
            
        }
        else if (muteProp == true)
        {
            
            originalString = "\(video_base_url)&event_family=\(event_family[1])&event_id=\(eventId)&session_id=\(sessionId)&property_id=\(gumletEnvironmentKey)&user_id=\(userId)&playback_id=\(playbackId)&player_instance_id=\(playerInstaceId)&event=\(event)from=\(seekingtime)&to=\(seekedTime)&playback_time_instant_millis=\(startPlayTimeInMS)&player_remote_played=\(playerRemotePlayed)&video_total_duration_millis=\(videoTotalDuration)&video_source_url=\(videoSourceUrl)&video_source_hostname=\(videoSourceHostName)&video_source_format=\(videoSourceType)&muted=\(muted)&previous_event=\(previousEvent)&millis_from_previous_event=\(previousEventTime)&video_width_pixels=\(videoWidthPixel)&video_height_pixels=\(videoHeightPixel)&bitrate_mbps=\(bitrateMbps)&z=\(localCurrentTime)&orientation=\(orientation)&orientation_from=\(orientation_from)&fullscreen=\(fullscreen)&video_downscale_percentage=\(videoDownScale)&video_upscale_percentage=\(videoUpscale)&custom_content_type=\("xyz")&custom_video_duration_millis=\("134598")&custom_encoding_variant=\("abc")&custom_video_language=\("Hindi")&custom_video_id=\("qwdr32efcSA")&custom_video_series=\("1A")&customVideoProducer=\("khush")&customVideotitle=\("Animated")&customVideoVariantName=\("alot")&customVideoVariant=\("super")&custom_data_1=\("data_1")&custom_data_2=\("data_2")&custom_data_3=\("data_3")&custom_data_4=\("data_4")&custom_data_5=\("data_5")&custom_data_6=\("data_6")&custom_data_7=\("data_7")&custom_data_8=\("data_8")&custom_data_9=\("data_9")&custom_data_10=\("data_10")"
            
        }
        let urlString = originalString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
        
        performRequest(urlString:urlString!)
    }
    
    //MARK:- call Network Request API
    func callNetworkRequestAPI(request_id:String,
                               session_id:String,
                               user_id:String,
                               source_id:String,
                               player_instance_id:String,
                               request_start:String,
                               request_response_start:String,
                               request_response_end:String,
                               request_type:String,
                               request_hostname:String,
                               request_bytes_loaded:Int64,
                               request_response_headers:String,
                               request_media_duration_millis:Int,
                               request_video_width_pixels:Float,
                               request_video_height_pixels:Float,
                               error_code:Int,
                               error:String,
                               error_text:String,
                               created_at:String)
    {
        let originalString = "\(video_base_url)&event_family=\(event_family[3])&request_id=\(request_id)&player_instance_id=\(player_instance_id)&property_id=\(source_id)&session_id=\(session_id)&user_id=\(user_id)&request_start=\(request_start)&request_response_start=\(request_response_start)&request_response_end=\(request_response_end)&request_type=\(request_type)&request_hostname=\(request_hostname)&request_bytes_loaded=\(request_bytes_loaded)&request_response_headers=\(request_response_headers)&request_media_duration_millis=\(request_media_duration_millis)&request_video_width_pixels=\(request_video_width_pixels)&request_video_height_pixels=\(request_video_height_pixels)&error_code=\(error_code)&error_text=\(error_text)&error=\(error)&z=\(created_at)"
        
        
        let urlString = originalString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
        
        performRequest(urlString:urlString!)
    }
    
    
    //MARK:- call Perform Reqeust
    
    func performRequest(urlString:String)
    {
        if let url = URL(string: urlString)
        {
            //create a url session
            let config = URLSessionConfiguration.default
            // default User-Agent: "User-Agent" = "UserAgentDemo/1 CFNetwork/1121.2.1 Darwin/19.2.0";
            // custom User-Agent
            let userAgent = getUserAgent()
            
            config.httpAdditionalHeaders = ["User-Agent": userAgent]
            let session = URLSession(configuration: config)
            
            //give the session  a task
            let task = session.dataTask(with: url,completionHandler:
                                            
                                            {  (data, response, error) in
                                                
                                                if error != nil
                                                {
                                                    
                                                    return
                                                }
                                                
                                                
                                                
                                                if let data = data {
                                                    
                                                    do{
                                                        
                                                        _ = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions())
                                                        
                                                    }
                                                    catch  {
                                                        print ("OOps not good JSON formatted response")
                                                    }
                                                }
                                            })
            // start the task
            task.resume()
        }
    }
    
}



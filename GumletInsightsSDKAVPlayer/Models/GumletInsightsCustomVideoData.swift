//
//  GumletSDKCustomVideoData.swift
//  GumletVideoAnalyticsSDK
//

//

import Foundation

public struct GumletInsightsCustomVideoData
{
    
 public var customContentType: String
 public var customVideoDurationMillis: String

 public var customEncodingVariant: String
 public var customVideoLanguage: String

 public var customVideoId: String
 public var customVideoSeries: String

 public var customVideoProducer: String
 public var customVideotitle: String
 
 public var customVideoVariantName: String
 public var customVideoVariant: String
 
    
    public init(){
    
        self.customContentType = ""
        self.customVideoDurationMillis = ""
       
        self.customVideoId = ""
        self.customVideoSeries = ""
        
        self.customVideoProducer = ""
        self.customVideotitle = ""
        
        self.customVideoVariantName = ""
        self.customVideoVariant = ""
        
        self.customEncodingVariant = ""
        self.customVideoLanguage = ""
        
    }
    
    public init(customContentType:String, customVideoDurationMillis:String, customEncodingVariant:String, customVideoLanguage:String, customVideoId:String, customVideoSeries:String, customVideoProducer:String, customVideotitle:String, customVideoVariantName:String, customVideoVariant:String) {
        self.customContentType = customContentType
        self.customVideoDurationMillis = customVideoDurationMillis
       
        self.customVideoId = customVideoId
        self.customVideoSeries = customVideoSeries
        
        self.customVideoProducer = customVideoProducer
        self.customVideotitle = customVideotitle
        
        self.customVideoVariantName = customVideoVariantName
        self.customVideoVariant = customVideoVariant
        
        self.customEncodingVariant = customEncodingVariant
        self.customVideoLanguage = customVideoLanguage
       
    }
}

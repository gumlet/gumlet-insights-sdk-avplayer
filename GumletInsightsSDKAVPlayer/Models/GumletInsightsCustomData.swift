//
//  GumletSDKCustomData.swift
//  GumletVideoAnalyticsSDK
//

//

import Foundation

public struct GumletInsightsCustomData {
    
   public var customUserId: String
    public var customData1: String
    public var customData2: String
    public var customData3: String
    public  var customData4: String
    public  var customData5: String
    public var customData6: String
    public var customData7: String
    public var customData8: String
    public var customData9: String
    public var customData10:String
    
  public init() {
        
    self.customUserId = ""
    self.customData1 = ""
    self.customData2 = ""
    self.customData3 = ""
    self.customData4 = ""
    self.customData5 = ""
    self.customData6 = ""
    self.customData7 = ""
    self.customData8 = ""
    self.customData9 = ""
    self.customData10 = ""

    }
    
    public init(customUserId:String, customData1:String, customData2:String, customData3:String, customData4:String, customData5:String, customData6:String, customData7:String, customData8:String, customData9:String, customData10:String) {
        self.customUserId = customUserId
        self.customData1 = customData1
        self.customData2 = customData2
        self.customData3 = customData3
        self.customData4 = customData4
        self.customData5 = customData5
        self.customData6 = customData6
        self.customData7 = customData7
        self.customData8 = customData8
        self.customData9 = customData9
        self.customData10 = customData10
    }
}

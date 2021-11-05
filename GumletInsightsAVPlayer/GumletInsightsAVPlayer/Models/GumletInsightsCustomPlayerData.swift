//
//  GumletVideoPlayerData.swift
//  GumletVideoAnalyticsSDK
//

//

import Foundation


public struct GumletInsightsCustomPlayerData {
  
  public var GumletPlayerName: String
  public var GumletPlayerIntegrationVersion: String
  public var gumletPageType:String
   
    public init()
    {
        self.GumletPlayerName = ""
        self.GumletPlayerIntegrationVersion = ""
        self.gumletPageType = ""
    }
   
   public init(gumletPageType:String,GumletPlayerIntegrationVersion:String,GumletPlayerName:String) {
      
       self.GumletPlayerName = GumletPlayerName
       self.GumletPlayerIntegrationVersion = GumletPlayerIntegrationVersion
       self.gumletPageType = gumletPageType
   
   }
}


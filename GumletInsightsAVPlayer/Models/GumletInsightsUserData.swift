//
//  GumletVideoUserData.swift
//  GumletVideoAnalyticsSDK
//

//

import Foundation
 
 public struct GumletInsightsUserData {
   public var userName: String
    public var userEmail: String
    public var userPhone: String
    public var userProfileImage: String
    public var userAddressLine1: String
    public  var userAddressLine2: String
    public var userCity: String
    public var userState: String
    public var userCountry: String
    public var userZipcode:String
    
   public init()
   {
    self.userName = ""
    self.userEmail = ""
    self.userPhone = ""
    self.userProfileImage = ""
    self.userAddressLine1 = ""
    self.userAddressLine2 =  ""
    self.userCity = ""
    self.userState = ""
    self.userCountry = ""
    self.userZipcode = ""
   }
    
    public init(userName:String, userEmail:String, userPhone:String, userProfileImage:String, userAddressLine1:String, userAddressLine2:String, userCity:String, userState:String, userCountry:String, userZipcode:String) {
        self.userName = userName
        self.userEmail = userEmail
        self.userPhone = userPhone
        self.userProfileImage = userProfileImage
        self.userAddressLine1 = userAddressLine1
        self.userAddressLine2 = userAddressLine2
        self.userCity = userCity
        self.userState = userState
        self.userCountry = userCountry
        self.userZipcode = userZipcode
       
    }
}


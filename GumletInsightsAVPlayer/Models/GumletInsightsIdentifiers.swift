//
//  GumletVideoIdentifiers.swift
//  GumletVideoAnalyticsSDK
//
//

import Foundation
class GumletInsightsIdentifiers {
    static let keychain = KeychainSwift()
    static let defaults = UserDefaults.standard
   
    //MARK:- Create IDs
    public class func randomStringForId(_ n: Int) -> String
    {
        let  digits = "abcdefghijklmnopqrstuvwxyz1234567890ABCDEFGHIJKLMNOPQRSTUVWXYZ"
        
        return String(Array(0..<n).map{
            _ in digits.randomElement()!
        })
    }
    
    public class var userId: String{
        return loadOrGenerateAnonymousID()
    }
    
    public class var sessionId: String{
        return loadOrGenerateSessionID()
    }
    
    public class var eventId: String{

        let event_id = randomStringForId(10)
        return event_id
    }
    
    public class var playerInstanceId: String{
        return loadOrGeneratePlayerInstanceID()
    }
    
    public class var playBackId: String{
        return loadOrGeneratePlayBackID()
    }
    
    
    public class var requestId: String{
        return loadOrGenerateRequestID()
    }
    
    private class func loadOrGenerateAnonymousID() -> String{
        if let anonymousId = keychain.get("userId"){
            return anonymousId
        }
        else{
            let anonymousId = UUID().uuidString
            keychain.set(anonymousId, forKey: "userId")
            return anonymousId
        }
    }
    
    
    private class func loadOrGeneratePlayerInstanceID() -> String{
        if let playerInstanceId = defaults.string(forKey: "playerInstanceId"){
            return playerInstanceId
        }
        else{
            let playerInstanceId = randomStringForId(10)
            defaults.setValue(playerInstanceId, forKey:"playerInstanceId")
            return playerInstanceId
        }
    }
    

    
    public class func loadOrGenerateSessionID() -> String {
        if let sessionId = defaults.string(forKey: "user_session"){
            if let date = defaults.object(forKey: "user_session_creation_time") as? Date {
                if let diff = Calendar.current.dateComponents([.hour], from: date, to: Date()).hour, diff > 12 {
                    return createNewSessionID()
                }
            }
           return sessionId
        }
        else{
            return createNewSessionID()
        }
    }
    
    
    public class func loadOrGeneratePlayBackID() -> String {
        if let playBackId = defaults.string(forKey: "PlayBackId"){
           
           return playBackId
        }
        else{
            return createplayBackId()
        }
    }
    
    public class func loadOrGenerateRequestID() -> String {
        if let requestId = defaults.string(forKey: "request_id"){
           
           return requestId
        }
        else{
            return createRequestId()
        }
    }
    
   
    
    public class func createNewSessionID() -> String{
        let sessionId = randomStringForId(10)
        defaults.setValue(sessionId, forKey: "user_session")
        defaults.set(Date(), forKey:"user_session_creation_time")
        return sessionId
    }
    
    public class func createplayBackId() -> String
    {
        let PlayBackId = randomStringForId(10)// UserDefaults.standard.setValue(plackBackId, forKey: "PlayBackId")
       
        defaults.setValue(PlayBackId, forKey: "PlayBackId")
        return PlayBackId
    }
    
    public class func createRequestId() -> String
    {
        let request_id = randomStringForId(10)
       
        defaults.setValue(request_id, forKey: "request_id")
        return request_id
    }
    
    
    
}

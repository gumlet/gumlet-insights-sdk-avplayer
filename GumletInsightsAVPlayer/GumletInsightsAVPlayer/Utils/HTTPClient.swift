//
//  HTTPClient.swift
//  GumletVideoAnalyticsSDK

//

import Foundation
import UIKit

enum HTTPClientErrors: Error {
    case badSession
    case statusCode(code: Int)
}

public class HTTPClient {
    private var session: URLSession
  
    
    init() {
        self.session = Self.configuredSession()
    }
    func getUserAgent() -> String
    {
       
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
        //        MyApp/1.8.199 (iOS; iPhone XS; Version 13.3 (Build 17C45)) CFNetwork/1121.2.1 Darvin/19.3.0
        //        User-Agent: <AppName/<version> (<iDevice platform>; <Apple model identifier>; iOS/<OS version>) CFNetwork/<version> Darwin/<version>
        
    }
    func performRequest(parameters:[String:Any]) {
        DispatchQueue.global(qos: .background).async {
            let strURL = parameters.queryString
            let escapedString = strURL.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)
            if let url = URL(string: Constants.API.BaseURL+"?"+escapedString!)
            {
               
                let task = self.session.dataTask(with: url) { data, response, error in
                    
                    if error != nil
                    {
                      
                        return
                    }
                    
                  
                    
                    if let data = data {
                        do{
                            _ = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions())
                           
                        }catch _ {
                            print ("OOps not good JSON formatted response")
                        }
                    }
                }
                task.resume()
            }
        }
    }
    
    deinit {
        // finish any tasks that may be processing
        session.finishTasksAndInvalidate()
    }
}

extension HTTPClient {
    internal static func configuredSession() -> URLSession {
        let configuration = URLSessionConfiguration.ephemeral
        configuration.allowsCellularAccess = true
        configuration.timeoutIntervalForResource = 30
        configuration.timeoutIntervalForRequest = 60
        configuration.httpAdditionalHeaders = ["User-Agent": "gumlet-analytics-ios/\(GumletInsightsSDK.version())"]
        let session = URLSession.init(configuration: configuration, delegate: nil, delegateQueue: nil)
        return session
    }
}

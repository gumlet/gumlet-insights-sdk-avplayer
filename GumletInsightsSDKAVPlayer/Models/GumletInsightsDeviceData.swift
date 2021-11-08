//
//  GumletVideoDeviceData.swift
//  GumletVideoAnalyticsSDK
//
//  
//

import Foundation
import UIKit
import MachO
public struct GumletInsightsDeviceData {

    public static func getDeviceData() -> [String:Any]{
        var device_is_touchscreen :Bool = true
        let device_name = UIDevice().type//UIDevice.current.name
        var device_category = ""
        switch UIDevice.current.userInterfaceIdiom.rawValue
        {
        case   0:
            device_category = "Phone"
            device_is_touchscreen = true
            break
        case 1:
            device_category = "iPad"
            device_is_touchscreen = true
            break
        case 2:
            device_category = "TV"
            device_is_touchscreen = false
            break
        case 3:
            device_category = "carPlay"
            device_is_touchscreen = true
            break
        case 4:
            device_category = "Mac"
            device_is_touchscreen = false
            break
        default:
            device_category = "Unspecified"
            device_is_touchscreen = true
            break
        }
        
        let device_manufacturer = "apple"
        
        let screenScale = UIScreen.main.scale
        
        let device_display_dpr = Float(screenScale)
        
        return ["meta_device_architecture":getArchitecture(),
        "meta_device_category":device_category,
        "meta_device_manufacturer":device_manufacturer,
        "meta_device_name":device_name,
        "meta_device_display_width":UIScreen.main.bounds.width,
        "meta_device_display_height":UIScreen.main.bounds.height,
        "meta_device_display_dpr":device_display_dpr,
        "meta_device_is_touchscreen":device_is_touchscreen]
    }
    
    private static func getArchitecture() -> String {
        let info = NXGetLocalArchInfo()
        let device_Arch =  NSString(utf8String: (info?.pointee.name)!)
        return device_Arch! as String
        
    }
}

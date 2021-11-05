//
//  GumletVideoOSData.swift
//  GumletVideoAnalyticsSDK
//
// 
//

import Foundation
import UIKit
public struct GumletInsightsOSData {
    var meta_operating_system = ""
    var meta_operating_system_version = ""
    public static func getOSData() -> [String:Any]{
        return ["meta_operating_system":UIDevice.current.systemName,
                "meta_operating_system_version":UIDevice.current.systemVersion]
    }
}

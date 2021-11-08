//
//  roundToDecimal.swift
//  GumletSDKVidAnalytics
//

//

import Foundation

extension Double {
    func roundToDecimal(_ fractionDigits: Int) -> Double {
        let multiplier = pow(10, Double(fractionDigits))
        return Darwin.round(self * multiplier) / multiplier
    }
//    let divisor = pow(10.0, Double(places))
//            return (self * divisor).rounded() / divisor
}

//
//  roundToDecimalFloat.swift
//  GumletSDKVidAnalytics
//

//

import Foundation

extension Float {
    func roundToDecimalFloat(_ fractionDigits: Int) -> Float {
        let divisor = pow(10.0, Float(fractionDigits))
        return (self * divisor).rounded() / divisor
    }
//    let divisor = pow(10.0, Double(places))
//            return (self * divisor).rounded() / divisor
}

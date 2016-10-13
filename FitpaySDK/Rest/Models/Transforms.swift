//
//  Transforms.swift
//  FitpaySDK
//
//  Created by Jakub Borowski on 6/2/16.
//  Copyright © 2016 Fitpay. All rights reserved.
//

import Foundation

import ObjectMapper

internal class NSTimeIntervalTransform: TransformType
{
    typealias Object = TimeInterval
    typealias JSON = Int64
    
    init() {}
    
    func transformFromJSON(_ value: Any?) -> Double?
    {
        if let timeInt = value as? NSNumber
        {
            return TimeInterval(timeInt.int64Value/1000)
        }
        if let timeStr = value as? String
        {
            return TimeInterval(atof(timeStr)/1000)
        }
        return nil
    }
    
    func transformToJSON(_ value: TimeInterval?) -> Int64?
    {
        if let epoch = value
        {
            let timeInt = Int64(epoch*1000)
            return timeInt
        }
        return nil
    }
}

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
    typealias Object = NSTimeInterval
    typealias JSON = NSNumber
    
    init() {}
    
    func transformFromJSON(value: AnyObject?) -> NSTimeInterval?
    {
        if let timeInt = value as? NSNumber
        {
            return NSTimeInterval(timeInt.integerValue)/1000
        }
        if let timeStr = value as? String
        {
            return NSTimeInterval(atof(timeStr))/1000
        }
        return nil
    }
    
    func transformToJSON(value: NSTimeInterval?) -> NSNumber?
    {
        if let epoch = value
        {
            return NSNumber(double: epoch*1000)
        }
        return nil
    }
}
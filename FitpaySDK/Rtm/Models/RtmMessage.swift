//
//  RtmMessage.swift
//  FitpaySDK
//
//  Created by Anton on 02.11.16.
//  Copyright © 2016 Fitpay. All rights reserved.
//

import UIKit
import ObjectMapper

open class RtmMessage: NSObject, Mappable {
    open var callBackId: String?
    open var data: String?
    open var action: String?
    
    public required init?(map: Map) {
        
    }
    
    internal override init() {
        super.init()
    }
        
    open func mapping(map: Map) {
        callBackId <- map["callBackId"]
        data <- map["data"]
        action <- map["type"]
    }
}

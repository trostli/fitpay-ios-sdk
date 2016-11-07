//
//  RtmMessageResponse.swift
//  FitpaySDK
//
//  Created by Anton on 02.11.16.
//  Copyright © 2016 Fitpay. All rights reserved.
//

import UIKit
import ObjectMapper

open class RtmMessageResponse: RtmMessage {

    var success: Bool?
    
    public required init(callbackId: Int? = nil, data: Any? = nil, type: String, success: Bool? = nil) {
        super.init()
        
        self.callBackId = callBackId
        self.data = data
        self.type = type
        self.success = success
    }
    
    public required init?(map: Map) {
        fatalError("init(map:) has not been implemented")
    }
    
}

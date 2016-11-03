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

    public required init(callbackId: String, data: String, action: String) {
        super.init()
        
        self.callBackId = callBackId
        self.data = data
        self.action = action
    }
    
    public required init?(map: Map) {
        fatalError("init(map:) has not been implemented")
    }
    
}

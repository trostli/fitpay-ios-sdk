//
//  FitpayEvent.swift
//  FitpaySDK
//
//  Created by Anton on 15.04.16.
//  Copyright © 2016 Fitpay. All rights reserved.
//

import UIKit

public class FitpayEvent: NSObject {

    private(set) var eventId : FitpayEventTypeProtocol
    private(set) var eventData : AnyObject
    
    init(eventId: FitpayEventTypeProtocol, eventData: AnyObject) {
        
        self.eventData = eventData
        self.eventId = eventId
        
        super.init()
    }
}

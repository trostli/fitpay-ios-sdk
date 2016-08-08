//
//  FitpayEvent.swift
//  FitpaySDK
//
//  Created by Anton on 15.04.16.
//  Copyright © 2016 Fitpay. All rights reserved.
//

public class FitpayEvent: NSObject {

    public private(set) var eventId : FitpayEventTypeProtocol
    public private(set) var eventData : AnyObject
    
    public init(eventId: FitpayEventTypeProtocol, eventData: AnyObject) {
        
        self.eventData = eventData
        self.eventId = eventId
        
        super.init()
    }
}

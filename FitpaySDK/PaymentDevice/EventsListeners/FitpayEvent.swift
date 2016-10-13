//
//  FitpayEvent.swift
//  FitpaySDK
//
//  Created by Anton on 15.04.16.
//  Copyright © 2016 Fitpay. All rights reserved.
//

open class FitpayEvent: NSObject {

    open fileprivate(set) var eventId : FitpayEventTypeProtocol
    open fileprivate(set) var eventData : Any
    
    public init(eventId: FitpayEventTypeProtocol, eventData: Any) {
        
        self.eventData = eventData
        self.eventId = eventId
        
        super.init()
    }
}

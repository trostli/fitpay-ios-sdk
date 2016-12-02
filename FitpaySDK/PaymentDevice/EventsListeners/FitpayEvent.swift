//
//  FitpayEvent.swift
//  FitpaySDK
//
//  Created by Anton on 15.04.16.
//  Copyright © 2016 Fitpay. All rights reserved.
//

public enum EventStatus: Int {
    case success = 0
    case failed
    
    public func toString() -> String {
        switch self {
        case .success:
            return "OK"
        case .failed:
            return "FAILED"
        }
    }
}

open class FitpayEvent: NSObject {

    open fileprivate(set) var eventId : FitpayEventTypeProtocol
    open fileprivate(set) var status: EventStatus
    open fileprivate(set) var reason: Error?
    open fileprivate(set) var date: Date
    
    open fileprivate(set) var eventData : Any
    
    public init(eventId: FitpayEventTypeProtocol, eventData: Any, status: EventStatus = .success, reason: Error? = nil) {
        
        self.eventData = eventData
        self.eventId = eventId
        self.status = status
        self.date = Date()
        self.reason = reason
        
        super.init()
    }
}

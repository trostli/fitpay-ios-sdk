//
//  FitpayEventBinding.swift
//  FitpaySDK
//
//  Created by Anton on 15.04.16.
//  Copyright © 2016 Fitpay. All rights reserved.
//

public class FitpayEventBinding : NSObject {
    static private var bindingIdCounter : Int = 0
    private let bindingId : Int
    
    public var eventId : FitpayEventTypeProtocol
    public var listener : FitpayEventListener
    
    public init(eventId: FitpayEventTypeProtocol, listener: FitpayEventListener) {

        self.eventId = eventId
        self.listener = listener
        
        bindingId = FitpayEventBinding.bindingIdCounter
        FitpayEventBinding.bindingIdCounter += 1
        
        super.init()
    }
}

extension FitpayEventBinding : FitpayEventListener {
    public func dispatchEvent(event: FitpayEvent) {
        listener.dispatchEvent(event)
    }
    
    public func invalidate() {
        listener.invalidate()
    }
}

public func ==(lhs: FitpayEventBinding, rhs: FitpayEventBinding) -> Bool {
    return lhs.bindingId == rhs.bindingId
}
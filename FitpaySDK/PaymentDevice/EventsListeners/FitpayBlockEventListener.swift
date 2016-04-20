//
//  FitpayBlockEventListener.swift
//  FitpaySDK
//
//  Created by Anton on 15.04.16.
//  Copyright © 2016 Fitpay. All rights reserved.
//


class FitpayBlockEventListener {
    
    typealias BlockCompletion = (event:FitpayEvent) -> Void
    
    var blockCompletion : BlockCompletion
    var completionQueue : dispatch_queue_t

    private var isValid : Bool = true
    
    required init(completion: BlockCompletion, queue: dispatch_queue_t = dispatch_get_main_queue()) {
        self.blockCompletion = completion
        self.completionQueue = queue
    }
}

extension FitpayBlockEventListener : FitpayEventListener {
    func dispatchEvent(event: FitpayEvent) {
        guard isValid else {
            return
        }
        
        dispatch_async(completionQueue) {
            _ in
            self.blockCompletion(event: event)
        }
    }
    
    func invalidate() {
        isValid = false
    }
}
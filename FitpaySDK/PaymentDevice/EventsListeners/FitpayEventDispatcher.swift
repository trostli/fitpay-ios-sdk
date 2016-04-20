//
//  FitpayEventDispatcher.swift
//  FitpaySDK
//
//  Created by Anton on 15.04.16.
//  Copyright © 2016 Fitpay. All rights reserved.
//


class FitpayEventDispatcher {
    internal var bindingsDictionary : [Int:[FitpayEventBinding]] = [:]
    
    func addListenerToEvent(listener: FitpayEventListener, eventId: FitpayEventTypeProtocol) -> FitpayEventBinding? {
        var bindingsArray = self.bindingsDictionary[eventId.eventId()]
        if bindingsArray == nil {
            bindingsArray = []
        }
        
        let binding = FitpayEventBinding(eventId: eventId, listener: listener)
        bindingsArray?.append(binding)
        
        self.bindingsDictionary[eventId.eventId()] = bindingsArray
        
        return binding
    }
    
    func removeBinding(binding: FitpayEventBinding) {
        if var bindingsArray = self.bindingsDictionary[binding.eventId.eventId()] {
            if bindingsArray.contains(binding) {
                binding.invalidate()
                bindingsArray.removeObject(binding)
                self.bindingsDictionary[binding.eventId.eventId()] = bindingsArray
            }
        }
    }
    
    func removeAllBindings() {
        for (_, bindingsArray) in self.bindingsDictionary {
            for binding in bindingsArray {
                binding.invalidate()
            }
        }
        
        self.bindingsDictionary.removeAll()
    }
    
    func dispatchEvent(event: FitpayEvent) {
        if let bindingsArray = self.bindingsDictionary[event.eventId.eventId()] {
            for binding in bindingsArray {
                binding.dispatchEvent(event)
            }
        }
    }
}
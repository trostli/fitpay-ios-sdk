//
//  FitpayEventListener.swift
//  FitpaySDK
//
//  Created by Anton on 15.04.16.
//  Copyright © 2016 Fitpay. All rights reserved.
//

public protocol FitpayEventListener {
    func dispatchEvent(_ event: FitpayEvent)
    func invalidate()
}

//
//  EventTypeProtocol.swift
//  FitpaySDK
//
//  Created by Anton on 15.04.16.
//  Copyright © 2016 Fitpay. All rights reserved.
//

import Foundation

protocol FitpayEventTypeProtocol {
    func eventId() -> Int
    func eventDescription() -> String
}
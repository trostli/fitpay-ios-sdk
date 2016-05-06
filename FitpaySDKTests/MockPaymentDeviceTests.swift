//
//  MockPaymentDeviceTests.swift
//  FitpaySDK
//
//  Created by Tim Shanahan on 5/6/16.
//  Copyright © 2016 Fitpay. All rights reserved.
//
import XCTest
import ObjectMapper
@testable import FitpaySDK

class MockPaymentDeviceTests: XCTestCase
{
    var paymentDevice : PaymentDevice!
    
    override func setUp()
    {
        super.setUp()
        let myPaymentDevice = PaymentDevice()
        self.paymentDevice = myPaymentDevice
        self.paymentDevice.changeDeviceInterface(MockPaymentDeviceInterface(paymentDevice: myPaymentDevice))
    }
    
    override func tearDown()
    {
        self.paymentDevice.removeAllBindings()
        self.paymentDevice = nil
        SyncManager.sharedInstance.removeAllSyncBindings()
        super.tearDown()
    }
    
    func testConnectToDeviceCheck()
    {
        // Async version - use once mock device eventing is in place
//        let expectation = super.expectationWithDescription("connection to device check")
//        self.paymentDevice.bindToEvent(eventType: PaymentDeviceEventTypes.OnDeviceConnected, completion:
//            {
//                (event) in
//                debugPrint("event: \(event), eventData: \(event.eventData)")
//                let deviceInfo = event.eventData["deviceInfo"] as? DeviceInfo
//                let error = event.eventData["error"]
//                
//                XCTAssertNil(error)
//                XCTAssertNotNil(deviceInfo)
//                XCTAssertNotNil(deviceInfo?.secureElementId)
//                
//                self.paymentDevice.disconnect()
//                
//                expectation.fulfill()
//        })
//        
//        self.paymentDevice.connect()
//        
//        super.waitForExpectationsWithTimeout(20, handler: nil)
        
        //TODO move to async testing above once mock device eventing is in place
        
        paymentDevice.connect();
        XCTAssertTrue(paymentDevice.isConnected, "device should be connected");
        XCTAssertNotNil(paymentDevice.deviceInfo, "device info should be populated")
    }
}

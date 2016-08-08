//
//  ApduResultMessage.swift
//  FitpaySDK
//
//  Created by Carol Bloch on 5/19/16.
//  Copyright © 2016 Fitpay. All rights reserved.
//

import Foundation

public class ApduResultMessage : NSObject {
    
    var msg : NSData
    var resultCode : UInt8
    var sequenceId : UInt16
    var responseCode: NSData
    var responseData: NSData
    
    public init(hexResult: String, sequenceId : String) {
        self.msg = hexResult.hexToData()!
        self.sequenceId = UInt16(sequenceId)!
        resultCode = UInt8(00)
        
        let range : NSRange = NSMakeRange(msg.length - 2, 2)
        var buffer = [UInt8](count: 2, repeatedValue: 0x00)
        msg.getBytes(&buffer, range: range)
        
        responseCode = NSData(bytes: buffer, length: 2)
        self.responseData = self.msg
        print("responseCode \(responseCode)")
    }
    
    public init(msg: NSData) {
        self.msg = msg
        var buffer = [UInt8](count: (msg.length), repeatedValue: 0x00)
        msg.getBytes(&buffer, length: buffer.count)
        
        resultCode = UInt8(buffer[0])
        
        var recvSeqId:UInt16?
        recvSeqId = UInt16(buffer[2]) << 8
        recvSeqId = recvSeqId! | UInt16(buffer[1])
        sequenceId = recvSeqId!
        
        var range : NSRange = NSMakeRange(msg.length - 2, 2)
        buffer = [UInt8](count: 2, repeatedValue: 0x00)
        msg.getBytes(&buffer, range: range)
        responseCode = NSData(bytes: buffer, length: 2)
        
        range = NSMakeRange(1, msg.length - 2)
        buffer = [UInt8](count: msg.length - 2, repeatedValue: 0x00)
        msg.getBytes(&buffer, range: range)
        responseData = NSData(bytes: buffer, length:  msg.length - 2)

    }
    
}
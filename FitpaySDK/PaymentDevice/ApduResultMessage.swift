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
    
    init(hexResult: String, sequenceId : String) {
        // This extension and it's counterpart in NSData don't seem to preserve the correct hex value
        self.msg = hexResult.hexToData()!;
        self.sequenceId = UInt16(sequenceId)!
        resultCode = UInt8(00)
        var buffer = [UInt8](count: (msg.length), repeatedValue: 0x00)
        msg.getBytes(&buffer, length: buffer.count)
        let range : NSRange = NSMakeRange(msg.length - 2, 2)
        buffer = [UInt8](count: 2, repeatedValue: 0x00)
        msg.getBytes(&buffer, range: range)
        
        responseCode = NSData(bytes: buffer, length: 2)
        print("responseCode \(responseCode)")
    }
    
    init(msg: NSData) {
        self.msg = msg
        var buffer = [UInt8](count: (msg.length), repeatedValue: 0x00)
        msg.getBytes(&buffer, length: buffer.count)
        
        resultCode = UInt8(buffer[0])
        
        var recvSeqId:UInt16?
        recvSeqId = UInt16(buffer[2]) << 8
        recvSeqId = recvSeqId! | UInt16(buffer[1])
        sequenceId = recvSeqId!
        
        let range : NSRange = NSMakeRange(msg.length - 2, 2)
        buffer = [UInt8](count: 2, repeatedValue: 0x00)
        msg.getBytes(&buffer, range: range)
        responseCode = NSData(bytes: buffer, length: 2)
    }
    
}
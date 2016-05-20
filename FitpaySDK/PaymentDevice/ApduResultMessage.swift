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
    
    public init(hexResult: String, sequenceId : String) {
        debugPrint("hexString \(hexResult), sequenceId \(sequenceId)")
        self.msg = hexResult.hexToData()!
        print("message \(msg)")
        self.sequenceId = UInt16(sequenceId)!
        resultCode = UInt8(00)
        var buffer = [UInt8](count: (msg.length), repeatedValue: 0x00)
        msg.getBytes(&buffer, length: buffer.count)
        print("message length \(msg.length)")
        let range : NSRange = NSMakeRange(msg.length - 2, 2)
        buffer = [UInt8](count: 2, repeatedValue: 0x00)
        msg.getBytes(&buffer, range: range)
        
        responseCode = NSData(bytes: buffer, length: 2)
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
        
        let range : NSRange = NSMakeRange(msg.length - 2, 2)
        buffer = [UInt8](count: 2, repeatedValue: 0x00)
        msg.getBytes(&buffer, range: range)
        responseCode = NSData(bytes: buffer, length: 2)
    }
    
}
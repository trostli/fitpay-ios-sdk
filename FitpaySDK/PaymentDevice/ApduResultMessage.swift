//
//  ApduResultMessage.swift
//  FitpaySDK
//
//  Created by Carol Bloch on 5/19/16.
//  Copyright © 2016 Fitpay. All rights reserved.
//

import Foundation

open class ApduResultMessage : NSObject {
    
    var msg : Data
    var resultCode : UInt8
    var sequenceId : UInt16
    var responseCode: Data
    var responseData: Data
    
    public init(hexResult: String, sequenceId : String) {
        self.msg = hexResult.hexToData()! as Data
        self.sequenceId = UInt16(sequenceId)!
        resultCode = UInt8(00)
        
        let range : NSRange = NSMakeRange(msg.count - 2, 2)
        var buffer = [UInt8](repeating: 0x00, count: 2)
        (msg as NSData).getBytes(&buffer, range: range)
        
        responseCode = Data(bytes: UnsafePointer<UInt8>(buffer), count: 2)
        self.responseData = self.msg
        print("responseCode \(responseCode)")
    }
    
    public init(msg: Data) {
        self.msg = msg
        var buffer = [UInt8](repeating: 0x00, count: (msg.count))
        (msg as NSData).getBytes(&buffer, length: buffer.count)
        
        resultCode = UInt8(buffer[0])
        
        var recvSeqId:UInt16?
        recvSeqId = UInt16(buffer[2]) << 8
        recvSeqId = recvSeqId! | UInt16(buffer[1])
        sequenceId = recvSeqId!
        
        var range : NSRange = NSMakeRange(msg.count - 2, 2)
        buffer = [UInt8](repeating: 0x00, count: 2)
        (msg as NSData).getBytes(&buffer, range: range)
        responseCode = Data(bytes: UnsafePointer<UInt8>(buffer), count: 2)
        
        range = NSMakeRange(1, msg.count - 2)
        buffer = [UInt8](repeating: 0x00, count: msg.count - 2)
        (msg as NSData).getBytes(&buffer, range: range)
        responseData = Data(bytes: UnsafePointer<UInt8>(buffer), count:  msg.count - 2)

    }
    
}

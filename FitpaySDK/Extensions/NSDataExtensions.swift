
import Foundation

extension NSData
{
    var UTF8String:String?
    {
        return self.stringWithEncoding(NSUTF8StringEncoding)
    }

    @inline(__always) func stringWithEncoding(encoding:NSStringEncoding) -> String?
    {
        return String(data: self, encoding: encoding)
    }

    var dictionary:Dictionary<String, AnyObject>?
    {
        guard let dictionary:[String : AnyObject] = try? NSJSONSerialization.JSONObjectWithData(self, options:.MutableContainers) as! [String : AnyObject] else
        {
            return nil
        }

        return dictionary
    }

    var errorMessages:[String]?
    {
        var messages:[String]?
        if let dict:[String : AnyObject] = self.dictionary
        {
            if let errors = dict["errors"] as? [[String : String]]
            {
                messages = []
                for error in errors
                {
                    if let message = error["message"]
                    {
                        messages!.append(message)
                    }
                }
            }
        }
        return messages
    }
    
    var errorMessage:String?
    {
        if let dict = self.dictionary
        {
            if let messageDict = dict as? [String : String]
            {
                if let message = messageDict["message"]
                {
                    return message
                }
            }
        }
        
        return nil
    }
    
    var SHA1:String?
    {
        let SHA_DIGEST_LENGTH = OpenSSLHelper.sharedInstance().shaDigestLength()
        let result = NSMutableData(length: Int(SHA_DIGEST_LENGTH*2))!
        guard OpenSSLHelper.sharedInstance().simpleSHA1(bytes, length: UInt(length), output: UnsafeMutablePointer<Int8>(result.mutableBytes)) else {
            return nil
        }
        return String(data: result, encoding: NSUTF8StringEncoding)
    }
    
    var hex:String
    {
        var s = ""
        
        var byte: UInt8 = 0
        for i in 0 ..< self.length {
            self.getBytes(&byte, range: NSMakeRange(i, 1))
            s += String(format: "%02x", byte)
        }
        
        return s
    }
    
    var reverseEndian:NSData {
        var inData = [UInt8](count: self.length, repeatedValue: 0)
        self.getBytes(&inData, length: self.length)
        var outData = [UInt8](count: self.length, repeatedValue: 0)
        var outPos = inData.count;
        for i in 0 ..< inData.count {
            outPos -= 1
            outData[i] = inData[outPos]
        }
        let out = NSData(bytes: outData, length: outData.count)
        return out
    }
}

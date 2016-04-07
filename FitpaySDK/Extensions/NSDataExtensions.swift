
import Foundation
import FPCrypto

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
        let result = NSMutableData(length: Int(SHA_DIGEST_LENGTH*2))!
        guard simpleSHA1(bytes, UInt(length), UnsafeMutablePointer<Int8>(result.mutableBytes)) else {
            return nil
        }
        return String(data: result, encoding: NSUTF8StringEncoding)
    }
}


import Foundation

extension NSError
{
    class func error <T:RawIntValue>(code code:T, domain:AnyClass, message:String) -> NSError
    {
        return NSError(domain: "\(domain.self)", code:code.rawValue, userInfo: [NSLocalizedDescriptionKey : message])
    }
    
    class func errorWithData(code code:Int, domain:AnyClass, data:NSData?, alternativeError:NSError? = nil) -> NSError
    {
        if let messages = data?.errorMessages
        {
            if messages.count > 0
            {
                return NSError(domain: "\(domain)", code:code, userInfo: [NSLocalizedDescriptionKey : messages[0]])
            }
        }
        else if let message = data?.UTF8String
        {
            return NSError(domain: "\(domain)", code:code, userInfo: [NSLocalizedDescriptionKey : message])
        }
        
        let userInfo:[NSObject : AnyObject] = alternativeError?.userInfo != nil ? alternativeError!.userInfo : [NSLocalizedDescriptionKey: ""]
        return NSError(domain: "\(domain)", code:code, userInfo: userInfo )
    }
    
    class func errorWithData<T:RawIntValue>(errorCode errorCode:T, domain:AnyClass, data:NSData?, alternativeError:NSError? = nil) -> NSError
    {
        return NSError.errorWithData(code:errorCode.rawValue, domain:domain, data:data, alternativeError:alternativeError)
    }

    class func unhandledError(domain:AnyClass) -> NSError
    {
        return NSError(domain:"\(domain)", code:0, userInfo: [NSLocalizedDescriptionKey : "Unhandled error"])
    }

    func errorWithData(data:NSData?)->NSError
    {
        if let data = data
        {
            let messages = data.errorMessages

            if messages.count > 0
            {
                return NSError(domain:self.domain, code:self.code, userInfo: [NSLocalizedDescriptionKey : messages[0]])
            }
            else if let string = data.UTF8String
            {
                return NSError(domain:self.domain, code:self.code, userInfo: [NSLocalizedDescriptionKey : string])
            }
        }

        return self
    }
}
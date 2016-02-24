
import Foundation

extension NSError
{
    class func error <T:RawIntValue>(code code:T, domain:AnyClass, message:String) -> NSError
    {
        return NSError(domain: "\(AnyClass.self)Domain", code:code.rawValue, userInfo: [NSLocalizedDescriptionKey : message])
    }
}
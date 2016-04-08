
import Foundation

extension NSJSONSerialization
{
    class func JSONString(object:AnyObject)->String?
    {
        guard let data = try? NSJSONSerialization.dataWithJSONObject(object, options: .PrettyPrinted),

        let string = String(data: data, encoding: NSUTF8StringEncoding) else
        {
            return nil
        }

        return string
    }
}


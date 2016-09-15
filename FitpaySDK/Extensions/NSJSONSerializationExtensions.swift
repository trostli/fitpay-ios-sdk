
import Foundation

extension JSONSerialization
{
    class func JSONString(_ object:AnyObject)->String?
    {
        guard let data = try? JSONSerialization.data(withJSONObject: object, options: .prettyPrinted),

        let string = String(data: data, encoding: String.Encoding.utf8) else
        {
            return nil
        }

        return string
    }
}


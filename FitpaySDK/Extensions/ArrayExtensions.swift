
extension Array
{
    var JSONString:String?
    {
        return Foundation.NSJSONSerialization.JSONString(self as! AnyObject)
    }
}
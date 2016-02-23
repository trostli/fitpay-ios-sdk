
extension Dictionary
{
    var JSONString:String?
    {
        return Foundation.NSJSONSerialization.JSONString(self)
    }
}

extension Array
{
    var JSONString:String?
    {
        return Foundation.NSJSONSerialization.JSONString(self as! AnyObject)
    }
}

extension _ArrayType where Generator.Element == ResourceLink
{
    func url(resource:String) -> String?
    {
        for link in self
        {
            if let target = link.target where target == resource
            {
                return link.href
            }
        }
        
        return nil
    }
}

extension Array where Element : Equatable {
    mutating func removeObject(object : Element) {
        if let index = self.indexOf(object) {
            self.removeAtIndex(index)
        }
    }
}
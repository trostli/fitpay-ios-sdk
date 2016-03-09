
import ObjectMapper

public class Relationship : Mappable
{
    public var links:[ResourceLink]?
    internal var card:CardInfo?
    public var device: DeviceInfo?
    
    public required init?(_ map: Map)
    {
        
    }
    
    public func mapping(map: Map)
    {
        links <- (map["_links"], ResourceLinkTransformType())
        card <- map["card"]
        device <- map["device"]
    }
}

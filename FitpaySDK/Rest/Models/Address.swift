
import ObjectMapper

public class Address : Mappable
{
    public var street1:String?
    public var street2:String?
    public var street3:String?
    public var city:String?
    public var state:String?
    public var postalCode:String?
    public var countryCode:String?
    
    public required init?(_ map: Map)
    {
        
    }
    
    public func mapping(map: Map)
    {
        self.street1 <- map["street1"]
        self.street2 <- map["street2"]
        self.street3 <- map["street3"]
        self.city <- map["city"]
        self.state <- map["state"]
        self.postalCode <- map["postalCode"]
        self.countryCode <- map["countryCode"]
    }
    
    
}

import ObjectMapper

internal class Address : Mappable
{
    var street1:String?
    var street2:String?
    var street3:String?
    var city:String?
    var state:String?
    var postalCode:String?
    var countryCode:String?
    
    required init?(_ map: Map)
    {
        
    }
    
    func mapping(map: Map)
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
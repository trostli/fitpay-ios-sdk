
import ObjectMapper

open class Address : Mappable
{
    open var street1:String?
    open var street2:String?
    open var street3:String?
    open var city:String?
    open var state:String?
    open var postalCode:String?
    open var countryCode:String?
    
    public required init?(_ map: Map)
    {
        
    }
    
    open func mapping(_ map: Map)
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

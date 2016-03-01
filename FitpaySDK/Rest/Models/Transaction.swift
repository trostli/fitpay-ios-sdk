
import ObjectMapper

public class Transaction : Mappable
{
    public var links:[ResourceLink]?
    public var transactionId:String?
    public var transactionType:String? //TODO: consider adding enum
    public var amount:Foundation.NSDecimalNumber? //TODO: consider keeping it as String
    public var currencyCode:String?  //TODO: consider adding enum
    public var authorizationStatus:String?  //TODO: consider adding enum
    public var transactionTime:String?
    public var transactionTimeEpoch:CLong?
    public var merchantName:String?
    public var merchantCode:String?
    public var merchantType:String?
    
    public required init?(_ map: Map)
    {
        
    }
    
    public func mapping(map: Map)
    {
        
    }
}

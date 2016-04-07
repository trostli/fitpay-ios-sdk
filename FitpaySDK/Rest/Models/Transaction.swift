
import ObjectMapper

public class Transaction : ClientModel, Mappable
{
    internal var links:[ResourceLink]?
    public var transactionId:String?
    public var transactionType:String?
    public var amount:Foundation.NSDecimalNumber? //TODO: consider keeping it as String
    public var currencyCode:String?
    public var authorizationStatus:String?
    public var transactionTime:String?
    public var transactionTimeEpoch:CLong?
    public var merchantName:String?
    public var merchantCode:String?
    public var merchantType:String?
    
    private static let selfResource = "self"
    internal weak var client:RestClient?
    
    public required init?(_ map: Map)
    {
        
    }
    
    public func mapping(map: Map)
    {
        links <- (map["_links"], ResourceLinkTransformType())
        transactionId <- map["transactionId"]
        transactionType <- map["transactionType"]
        amount <- map["amount"]
        currencyCode <- map["currencyCode"]
        authorizationStatus <- map["authorizationStatus"]
        transactionTime <- map["transactionTime"]
        transactionTimeEpoch <- map["transactionTimeEpoch"]
        merchantName <- map["merchantName"]
        merchantCode <- map["merchantCode"]
        merchantType <- map["merchantType"]
    }
}

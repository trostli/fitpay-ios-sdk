
import ObjectMapper

open class Transaction : NSObject, ClientModel, Mappable
{
    internal var links:[ResourceLink]?
    open var transactionId:String?
    open var transactionType:String?
    open var amount:Foundation.NSDecimalNumber? //TODO: consider keeping it as String
    open var currencyCode:String?
    open var authorizationStatus:String?
    open var transactionTime:String?
    open var transactionTimeEpoch:TimeInterval?
    open var merchantName:String?
    open var merchantCode:String?
    open var merchantType:String?
    
    fileprivate static let selfResource = "self"
    internal weak var client:RestClient?
    
    public required init?(map: Map)
    {
        
    }
    
    open func mapping(map: Map)
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

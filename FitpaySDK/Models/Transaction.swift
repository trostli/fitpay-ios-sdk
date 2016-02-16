
class Transaction
{
    var links:[ResourceLink]?
    var transactionId:String?
    var transactionType:String? //TODO: consider adding enum
    var amount:Foundation.NSDecimalNumber? //TODO: consider keeping it as String
    var currencyCode:String?  //TODO: consider adding enum
    var authorizationStatus:String?  //TODO: consider adding enum
    var transactionTime:String?
    var transactionTimeEpoch:Int?
    var merchantName:String?
    var merchantCode:String?
    var merchantType:String?
}

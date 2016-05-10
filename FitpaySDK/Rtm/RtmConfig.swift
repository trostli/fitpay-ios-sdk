import ObjectMapper

public class RtmConfig: NSObject, Mappable {
    public var clientId: String?
    public var redirectUri: String?
    public var paymentDevice: DeviceInfo?
    
    public init(clientId:String, redirectUri:String, paymentDevice:DeviceInfo) {
        self.clientId = clientId
        self.redirectUri = redirectUri
        self.paymentDevice = paymentDevice
    }
    
    public required init?(_ map: Map) {
        
    }
    
    public func mapping(map: Map) {
        clientId <- map["clientId"]
        redirectUri <- map["redirectUri"]
        paymentDevice <- map["paymentDevice"]
    }

}
import ObjectMapper

public class RtmConfig: NSObject, Mappable {
    public var clientId: String?
    public var redirectUri: String?
    public var userEmail: String?
    public var deviceInfo: DeviceInfo?
    public var hasAccount: Bool?
    public var version: String?
    
    public init(clientId:String, redirectUri:String, userEmail:String?, deviceInfo:DeviceInfo?, hasAccount:Bool = false) {
        self.clientId = clientId
        self.redirectUri = redirectUri
        self.userEmail = userEmail
        self.deviceInfo = deviceInfo
        self.hasAccount = hasAccount
    }
    
    public required init?(_ map: Map) {
        
    }
    
    public func mapping(map: Map) {
        clientId <- map["clientId"]
        redirectUri <- map["redirectUri"]
        userEmail <- map["userEmail"]
        deviceInfo <- map["paymentDevice"]
        hasAccount <- map["account"]
        version <- map["version"]
    }

}
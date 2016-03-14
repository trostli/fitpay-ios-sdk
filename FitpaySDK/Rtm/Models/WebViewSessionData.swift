
import ObjectMapper

/// This data can be used to set or verify a user device relationship, retrieve commit changes for the device, etc...
public class WebViewSessionData : Mappable
{
    public var userId:String?
    public var deviceId:String?
    public var token:String?
    
    internal var encryptedData:String?
    
    public required init?(_ map: Map)
    {
        
    }
    
    public func mapping(map: Map)
    {
        encryptedData <- map["encryptedData"]
        userId <- map["userId"]
        deviceId <- map["deviceId"]
        token <- map["token"]
    }
    
    internal func applySecret(secret:NSData, expectedKeyId:String?)
    {
        if let tmpSession : WebViewSessionData = JWEObject.decrypt(encryptedData, expectedKeyId: expectedKeyId, secret: secret) {
            self.userId = tmpSession.userId
            self.deviceId = tmpSession.deviceId
            self.token = tmpSession.token
        }
    }
}


import ObjectMapper

public class User : Mappable, SecretApplyable
{
    public var links:[ResourceLink]?
    public var id:String?
    public var created:String?
    public var createdEpoch:CLong?
    public var lastModified:String?
    public var lastModifiedEpoch:CLong?
    internal var encryptedData:String?
    internal var info:UserInfo?
    
    public required init?(_ map: Map)
    {
        
    }
    
    public func mapping(map: Map)
    {
        links <- (map["_links"], ResourceLinkTransformType())
        id <- map["id"]
        created <- map["createdTs"]
        createdEpoch <- map["createdTsEpoch"]
        lastModified <- map["lastModifiedTs"]
        lastModifiedEpoch <- map["lastModifiedTsEpoch"]
        encryptedData <- map["encryptedData"]
    }
    
    internal func applySecret(secret:NSData, expectedKeyId:String?)
    {
        if let encryptedData = self.encryptedData
        {
            let jweResult = JWEObject.parse(payload: encryptedData)

            if let kid = jweResult?.header?.kid, let expectedKeyId = expectedKeyId
            {
                // decrypt only if keys match
                if kid == expectedKeyId
                {
                    if let decryptResult = try? jweResult?.decrypt(secret)
                    {
                        self.info = Mapper<UserInfo>().map(decryptResult)
                    }
                }
            }
        }
    }
}


internal class UserInfo : Mappable
{
    var firstName:String?
    var lastName:String?
    var birthDate:String?
    var email:String?
    
    required init?(_ map: Map)
    {

    }
    
    func mapping(map: Map)
    {
        self.firstName <- map["firstName"]
        self.lastName <- map["lastName"]
        self.birthDate <- map["birthDate"]
        self.email <- map["email"]
    }
}



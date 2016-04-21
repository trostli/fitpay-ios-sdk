
import ObjectMapper

public class EncryptionKey : NSObject, Mappable
{
    internal var links:[ResourceLink]?
    public var keyId:String?
    public var created:String?
    public var createdEpoch:CLong?
    public var serverPublicKey:String?
    public var clientPublicKey:String?
    public var active:Bool?

    public required init?(_ map: Map)
    {

    }

    public func mapping(map: Map)
    {
        links <- (map["_links"], ResourceLinkTransformType())
        keyId <- map["keyId"]
        created <- map["createdTs"]
        createdEpoch <- map["createdTsEpoch"]
        serverPublicKey <- map["serverPublicKey"]
        clientPublicKey <- map["clientPublicKey"]
        active <- map["active"]
    }
}



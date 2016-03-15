
import ObjectMapper

public class Commit : ClientModel, Mappable, SecretApplyable
{
    var links:[ResourceLink]?
    var commitType:CommitType?
    var payload:Payload?
    var created:CLong?
    var previousCommit:String?
    var commit:String?
    
    internal weak var client:RestClient?
    
    internal var encryptedData:String?
    
    public required init?(_ map: Map)
    {
        
    }
    
    public func mapping(map: Map)
    {
        links <- (map["_links"], ResourceLinkTransformType())
        commitType <- map["commitType"]
        created <- map["createdTs"]
        previousCommit <- map["previousCommit"]
        commit <- map["commitId"]
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
                        self.payload = Mapper<Payload>().map(decryptResult)
                    }
                }
            }
        }
    }
}

public enum CommitType : String
{
    case CREDITCARD_CREATED = "CREDITCARD_CREATED"
    case CREDITCARD_DEACTIVATED = "CREDITCARD_DEACTIVATED"
    case CREDITCARD_ACTIVATED = "CREDITCARD_ACTIVATED"
    case CREDITCARD_DELETED = "CREDITCARD_DELETED"
    case RESET_DEFAULT_CREDITCARD = "RESET_DEFAULT_CREDITCARD"
    case SET_DEFAULT_CREDITCARD = "SET_DEFAULT_CREDITCARD"
    case APDU_PACKAGE = "APDU_PACKAGE"
}

public class Payload : Mappable
{
    var info = [String : AnyObject]()
    
    public required init?(_ map: Map)
    {
        
    }
    
    public func mapping(map: Map)
    {
        info = map.JSONDictionary
    }
}
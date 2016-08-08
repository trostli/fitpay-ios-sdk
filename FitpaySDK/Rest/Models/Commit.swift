
import ObjectMapper

public class Commit : NSObject, ClientModel, Mappable, SecretApplyable
{
    var links:[ResourceLink]?
    public var commitType:CommitType?
    public var payload:Payload?
    public var created:CLong?
    public var previousCommit:String?
    public var commit:String?
    
    private static let apduResponseResource = "apduResponse"
    
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
        self.payload = JWEObject.decrypt(self.encryptedData, expectedKeyId: expectedKeyId, secret: secret)
    }
    
    internal func confirmAPDU(completion:RestClient.ConfirmAPDUPackageHandler) {
        print("in the confirmAPDU method")
        guard self.commitType == CommitType.APDU_PACKAGE else {
            completion(error: NSError.unhandledError(Commit.self))
            return
        }
        
        let resource = Commit.apduResponseResource
        guard let url = self.links?.url(resource) else {
            completion(error: NSError.clientUrlError(domain:Commit.self, code:0, client: client, url: nil, resource: resource))
            return
        }
        
        guard let client = self.client else {
            completion(error: NSError.clientUrlError(domain:Commit.self, code:0, client: nil, url: url, resource: resource))
            return
        }
        
        guard let apduPackage = self.payload?.apduPackage else {
            completion(error: NSError.unhandledError(Commit.self))
            return
        }
        debugPrint("apdu package \(apduPackage)")
        client.confirmAPDUPackage(url, package: apduPackage, completion: completion)
    }
}

public enum CommitType : String
{
    case CREDITCARD_CREATED = "CREDITCARD_CREATED"
    case CREDITCARD_DEACTIVATED = "CREDITCARD_DEACTIVATED"
    case CREDITCARD_ACTIVATED = "CREDITCARD_ACTIVATED"
    case CREDITCARD_REACTIVATED = "CREDITCARD_REACTIVATED"
    case CREDITCARD_DELETED = "CREDITCARD_DELETED"
    case RESET_DEFAULT_CREDITCARD = "RESET_DEFAULT_CREDITCARD"
    case SET_DEFAULT_CREDITCARD = "SET_DEFAULT_CREDITCARD"
    case APDU_PACKAGE = "APDU_PACKAGE"
}

public class Payload : NSObject, Mappable
{
    public var creditCard:CreditCard?
    internal var payloadDictionary:[String : AnyObject]?
    internal var apduPackage:ApduPackage?
    
    public required init?(_ map: Map)
    {
        
    }
    
    public func mapping(map: Map)
    {
        let info = map.JSONDictionary
        
        if let _ = info["creditCardId"]
        {
            self.creditCard = Mapper<CreditCard>().map(info)
        }
        else if let _ = info["packageId"]
        {
            self.apduPackage = Mapper<ApduPackage>().map(info)
        }
        
        self.payloadDictionary = info
    }
}

import ObjectMapper

public class VerificationMethod : ClientModel, Mappable
{
    public var links:[ResourceLink]?
    public var verificationId:String?
    public var state:String? //TODO: consider creating enum
    public var methodType:String? //TODO: consider creating enum
    public var value:String?
    public var verificationResult:String? //TODO: consider creating enum
    public var created:String?
    public var createdEpoch:CLong?
    public var lastModified:String?
    public var lastModifiedEpoch:CLong?
    public var verified:String?
    public var verifiedEpoch:String?
    private static let selectResource = "select"
    private static let verifyResource = "verify"
    
    internal weak var client:RestClient?
    
    public required init?(_ map: Map)
    {
        
    }
    
    public func mapping(map: Map)
    {
        self.links <- (map["_links"], ResourceLinkTransformType())
        self.verificationId <- map["verificationId"]
        self.state <- map["state"]
        self.methodType <- map["methodType"]
        self.value <- map["value"]
        self.verificationResult <- map["verificationResult"]
        self.created <- map["createdTs"]
        self.createdEpoch <- map["createdTsEpoch"]
        self.lastModified <- map["lastModifiedTs"]
        self.lastModifiedEpoch <- map["lastModifiedTsEpoch"]
        self.verified <- map["verifiedTs"]
        self.verifiedEpoch <- map["verifiedTsEpoch"]
    }
    
    internal func selectVerificationType(completion:RestClient.SelectVerificationTypeHandler)
    {
        let resource = VerificationMethod.selectResource
        let url = self.links?.url(resource)
        if  let url = url, client = self.client
        {
            client.selectVerificationType(url, completion: completion)
        }
        else
        {
            completion(pending: false, verificationMethod: nil, error: NSError.clientUrlError(domain:CreditCard.self, code:0, client: client, url: url, resource: resource))
        }
    }
}

internal class VerificationMethodTransformType : TransformType
{
    typealias Object = [VerificationMethod]
    typealias JSON = [[String:AnyObject]]
    
    func transformFromJSON(value: AnyObject?) -> [VerificationMethod]?
    {
        if let items = value as? [[String:AnyObject]]
        {
            var list = [VerificationMethod]()
            
            for raw in items
            {
                if let item = Mapper<VerificationMethod>().map(raw)
                {
                    list.append(item)
                }
            }
            
            return list
        }
        
        return nil
    }
    
    func transformToJSON(value:[VerificationMethod]?) -> [[String:AnyObject]]?
    {
        return nil
    }
}

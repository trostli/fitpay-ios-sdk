
import ObjectMapper

public class DeviceInfo : ClientModel, Mappable, SecretApplyable
{
    public var links:[ResourceLink]?
    public var deviceIdentifier:String?
    public var deviceName:String?
    public var manufacturerName:String?
    public var serialNumber:String?
    public var modelNumber:String?
    public var hardwareRevision:String?
    public var firmwareRevision:String?
    public var softwareRevision:String?
    public var createdEpoch:CLong?
    public var created:String?
    public var osName:String?
    public var systemId:String?
    public var cardRelationships:[CardRelationship]?
    public var licenseKey:String?
    public var bdAddress:String?
    public var pairing:String?
    public var secureElementId:String?
    private static let userResource = "user"
    private static let commitsResource = "commits"
    private static let selfResource = "self"
    private weak var _client:RestClient?

    // Extra metadata specific for a particural type of device
    public var metadata:[String : AnyObject]?
    
    internal var client:RestClient?
    {
        get
        {
            return self._client
        }
        set
        {
            self._client = newValue
            
            if let cardRelationships = self.cardRelationships
            {
                for cardRelationship in cardRelationships
                {
                    cardRelationship.client = self.client
                }
            }
        }
    }
    
    public required init?(_ map: Map)
    {
        
    }
    
    public func mapping(map: Map)
    {
        links <- (map["_links"], ResourceLinkTransformType())
        created <- map["createdTs"]
        createdEpoch <- map["createdTsEpoch"]
        deviceIdentifier <- map["deviceIdentifier"]
        deviceName <- map["deviceName"]
        manufacturerName <- map["manufacturerName"]
        serialNumber <- map["serialNumber"]
        modelNumber <- map["modelNumber"]
        hardwareRevision <- map["hardwareRevision"]
        firmwareRevision <- map["firmwareRevision"]
        softwareRevision <- map["softwareRevision"]
        osName <- map["osName"]
        systemId <- map["systemId"]
        licenseKey <- map["licenseKey"]
        bdAddress <- map["bdAddress"]
        pairing <- map["pairing"]
        secureElementId <- map["secureElementId"]
        
        if let cardRelationships = map["cardRelationships"].currentValue as? [AnyObject] {
            if cardRelationships.count > 0 {
                self.cardRelationships = [CardRelationship]()
                
                for itrObj in cardRelationships {
                    if let parsedObj = Mapper<CardRelationship>().map(itrObj) {
                        self.cardRelationships!.append(parsedObj)
                    }
                }
            }
        }
        
        metadata = map.JSONDictionary
    }
    
    func applySecret(secret:NSData, expectedKeyId:String?) {
        if let cardRelationships = self.cardRelationships {
            for modelObject in cardRelationships {
                modelObject.applySecret(secret, expectedKeyId: expectedKeyId)
            }
        }
    }
    
    func delete(completion:RestClient.DeleteDeviceHandler) {
        let resource = DeviceInfo.selfResource
        let url = self.links?.url(resource)
        if  let url = url, client = self.client
        {
            client.deleteDevice(url, completion: completion)
        }
        else
        {
            completion(error: NSError.clientUrlError(domain:DeviceInfo.self, code:0, client: client, url: url, resource: resource))
        }
    }
    
    func update(firmwareRevision:String?, softwareRevision:String?, completion:RestClient.UpdateDeviceHandler) {
        let resource = DeviceInfo.selfResource
        let url = self.links?.url(resource)
        if  let url = url, client = self.client
        {
            client.updateDevice(url, firmwareRevision: firmwareRevision, softwareRevision: softwareRevision, completion: completion)
        }
        else
        {
            completion(device: nil, error: NSError.clientUrlError(domain:DeviceInfo.self, code:0, client: client, url: url, resource: resource))
        }
    }
    
    func listCommits(commitsAfter:String, limit:Int, offset:Int, completion:RestClient.CommitsHandler) {
        let resource = DeviceInfo.commitsResource
        let url = self.links?.url(resource)
        if  let url = url, client = self.client
        {
            client.commits(url, commitsAfter: commitsAfter, limit: limit, offset: offset, completion: completion)
        }
        else
        {
            completion(result: nil, error: NSError.clientUrlError(domain:DeviceInfo.self, code:0, client: client, url: url, resource: resource))
        }
    }
    
    func user(completion:RestClient.UserHandler) {
        let resource = DeviceInfo.userResource
        let url = self.links?.url(resource)
        if  let url = url, client = self.client
        {
            client.user(url, completion: completion)
        }
        else
        {
            completion(user: nil, error: NSError.clientUrlError(domain:DeviceInfo.self, code:0, client: client, url: url, resource: resource))
        }
    }
}

public class CardRelationship : ClientModel, Mappable, SecretApplyable
{
    public var links:[ResourceLink]?
    public var creditCardId:String?
    public var pan:String?
    public var expMonth:Int?
    public var expYear:Int?
    
    internal var encryptedData:String?
    private static let selfResource = "self"
    internal weak var client:RestClient?
    
    public required init?(_ map: Map)
    {
        
    }
    
    public func mapping(map: Map)
    {
        links <- (map["_links"], ResourceLinkTransformType())
        creditCardId <- map["creditCardId"]
        encryptedData <- map["encryptedData"]
        pan <- map["pan"]
        expMonth <- map["expMonth"]
        expYear <- map["expYear"]
    }
    
    internal func applySecret(secret:NSData, expectedKeyId:String?)
    {
        if let decryptedObj : CardRelationship? = JWEObject.decrypt(self.encryptedData, expectedKeyId: expectedKeyId, secret: secret) {
            self.pan = decryptedObj?.pan
            self.expMonth = decryptedObj?.expMonth
            self.expYear = decryptedObj?.expYear
        }
    }
    
    func relationship(completion:RestClient.RelationshipHandler) {
        let resource = CardRelationship.selfResource
        let url = self.links?.url(resource)
        if let url = url, client = self.client
        {
            client.relationship(url, completion: completion)
        }
        else
        {
            completion(relationship: nil, error: NSError.clientUrlError(domain:CardRelationship.self, code:0, client: client, url: url, resource: resource))
        }
    }
}

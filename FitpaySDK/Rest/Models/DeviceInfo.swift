
import ObjectMapper

public class DeviceInfo : Mappable, SecretApplyable
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

    // Extra metadata specific for a particural type of device
    public var metadata:[String : AnyObject]?
    
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
}

public class CardRelationship : Mappable, SecretApplyable
{
    public var links:[ResourceLink]?
    public var creditCardId:String?
    public var pan:String?
    public var expMonth:Int?
    public var expYear:Int?
    
    internal var encryptedData:String?
    
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
}

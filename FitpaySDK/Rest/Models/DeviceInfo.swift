
import ObjectMapper

public class DeviceInfo : Mappable
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
        //TODO: cardRelationships
        // cardRelationships <- map["cardRelationships"]
        
        metadata = map.JSONDictionary
    }
}

public class CardRelationship
{
    public var links:[ResourceLink]?
    public var pan:String?
    public var expMonth:String?
    public var expYear:String?
}

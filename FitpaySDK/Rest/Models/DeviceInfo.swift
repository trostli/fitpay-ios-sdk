
public class DeviceInfo
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
    public var createdEpoch:Int64?
    public var created:String?
    public var osName:String?
    public var systemId:String?
    public var cardRelationships:[CardRelationship]?
    public var licenseKey:String?
    public var bdAddress:String?
    public var pairing:String?
    public var secureElementId:String?

    // Extra metadata specific for a particural type of device
    var metadata = [String : AnyObject]()
}

public class CardRelationship
{
    public var links:[ResourceLink]?
    public var pan:String?
    public var expMonth:String?
    public var expYear:String?
}

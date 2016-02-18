
class DeviceInfo
{
    var links:[ResourceLink]?
    var deviceIdentifier:String?
    var deviceName:String?
    var manufacturerName:String?
    var serialNumber:String?
    var modelNumber:String?
    var hardwareRevision:String?
    var firmwareRevision:String?
    var softwareRevision:String?
    var createdEpoch:Int?
    var created:String?
    var osName:String?
    var systemId:String?
    var cardRelationships:[CardRelationship]?
    var licenseKey:String?
    var bdAddress:String?
    var pairing:String?
    var secureElementId:String?
}

class CardRelationship
{
    var links:[ResourceLink]?
    var pan:String?
    var expMonth:String?
    var expYear:String?
}

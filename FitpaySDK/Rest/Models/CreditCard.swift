
import Foundation

public class CreditCard
{
    public var links:[ResourceLink]?
    public var creditCardId:String?
    public var userId:String?
    public var isDefault:Bool?
    public var created:String?
    public var createdEpoch:Int64?
    public var state:String?
    public var cardType:String?
    public var cardMetaData:CardMetadata?
}

public class CardMetadata
{
    public var labelColor:String?
    public var issuerName:String?
    public var shortDescription:String?
    public var longDescription:String?
    public var contactUrl:String?
    public var contactPhone:String?
    public var contactEmail:String?
    public var termsAndConditionsUrl:String?
    public var privacyPolicyUrl:String?
    public var brandLogo:[Image]?
    public var cardBackground:[Image]?
    public var cardBackgroundCombined:[Image]?
    public var coBrandLogo:[Image]?
    public var icon:[Image]?
    public var termsAssetId:String?
    public var termsAssetReferences:[TermsAssetReferences]?
    public var eligibilityExpiration:String?
    public var eligibilityExpirationEpoch:Int64?
    public var deviceRelationships:[DeviceRelationships]?
    public var encryptedData:String?
}

public class Image
{
    public var links: [ResourceLink]?
    public var mimeType:String?
    public var height:Int?
    public var width:Int?
}

public class TermsAssetReferences
{
    public var links: [ResourceLink]?
    public var mimeType:String?
}

public class DeviceRelationships
{
    public var deviceType:String?
    public var links: [ResourceLink]?
    public var deviceIdentifier:String?
    public var manufacturerName:String?
    public var deviceName:String?
    public var serialNumber:String?
    public var modelNumber:String?
    public var hardwareRevision:String?
    public var firmwareRevision:String?
    public var softwareRevision:String?
    public var created:String?
    public var createdEpoch:Int64?
    public var osName:String?
    public var systemId:String?
}

public class CardInfo
{
    public var pan:String?
    public var expMonth:Int?
    public var expYear:Int?
    public var cvv:Int?
    public var address:Address?
}
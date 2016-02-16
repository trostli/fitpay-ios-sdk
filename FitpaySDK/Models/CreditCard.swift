
import Foundation

class CreditCard
{
    var links:[ResourceLink]?
    var creditCardId:String?
    var userId:String?
    var isDefault:Bool?
    var created:String?
    var createdEpoch:Int?
    var state:String?
    var cardType:String?
    var cardMetaData:CardMetadata?
}

class CardMetadata
{
    var labelColor:String?
    var issuerName:String?
    var shortDescription:String?
    var longDescription:String?
    var contactUrl:String?
    var contactPhone:String?
    var contactEmail:String?
    var termsAndConditionsUrl:String?
    var privacyPolicyUrl:String?
    var brandLogo:[Image]?
    var cardBackground:[Image]?
    var cardBackgroundCombined:[Image]?
    var coBrandLogo:[Image]?
    var icon:[Image]?
    var termsAssetId:String?
    var termsAssetReferences:[TermsAssetReferences]?
    var eligibilityExpiration:String?
    var eligibilityExpirationEpoch:Int?
    var deviceRelationships:[DeviceRelationships]?
    var encryptedData:String?
}


class Image
{
    var links: [ResourceLink]?
    var mimeType:String?
    var height:Int?
    var width:Int?
}

class TermsAssetReferences
{
    var links: [ResourceLink]?
    var mimeType:String?
}

class DeviceRelationships
{
    var deviceType:String?
    var links: [ResourceLink]?
    var deviceIdentifier:String?
    var manufacturerName:String?
    var deviceName:String?
    var serialNumber:String?
    var modelNumber:String?
    var hardwareRevision:String?
    var firmwareRevision:String?
    var softwareRevision:String?
    var created:String?
    var createdTsEpoch:Int?
    var osName:String?
    var systemId:String?
}

class CardInfo
{
    var pan:String?
    var expMonth:Int?
    var expYear:Int?
    var cvv:Int?
    var address:Address?
}

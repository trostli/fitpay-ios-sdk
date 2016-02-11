
import Foundation

class CreditCard
{
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
    var brandLogo:[BrandLogo]?
    var cardBackground:[CardBackground]?
    var cardBackgroundCombined:[CardBackgroundCombined]?
    var coBrandLogo:[CoBrandLogo]?
    var icon:[Icon]?
    var termsAssetId:String?
    var termsAssetReferences:[TermsAssetReferences]?
    var eligibilityExpiration:String?
    var eligibilityExpirationEpoch:Int?
}

class BrandLogo : Image {}

class CardBackground : Image {}

class CardBackgroundCombined : Image {}

class CoBrandLogo : Image {}

class Icon : Image {}

class IssuerLogo : Image {}

class Image
{
    var links:ResourceLinks?
    var mimeType:String?
    var height:Int?
    var width:Int?
}

class TermsAssetReferences
{
    var links:ResourceLinks?
    var mimeType:String?
}

class DeviceRelationships
{
    var deviceType:String?
    var links:ResourceLinks?
    var deviceIdentifier:String?
    var manufacturerName:String?
    var deviceName:String?
}
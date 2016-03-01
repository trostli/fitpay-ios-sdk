
import Foundation
import ObjectMapper

public class CreditCard : Mappable
{
    public var links:[ResourceLink]?
    public var creditCardId:String?
    public var userId:String?
    public var isDefault:Bool?
    public var created:String?
    public var createdEpoch:CLong?
    public var lastModifiedEpoch:CLong?
    public var state:String?
    public var cardType:String?
    public var cardMetaData:CardMetadata?
    // TODO: Parse fields below
    public var targetDeviceId:String?
    public var targetDeviceType:String?
    public var verificationMethods:[VerificationMethod]?
    public var deviceRelationships:[DeviceRelationships]?
    internal var encryptedData:String?
    public var externalTokenReference:String?
    public var lastModified:String?

    public var termsAssetId:String?
    public var termsAssetReferences:[TermsAssetReferences]?
    public var eligibilityExpiration:String?
    public var eligibilityExpirationEpoch:CLong?
    
    public required init?(_ map: Map)
    {
        
    }
    
    public func mapping(map: Map)
    {
        self.links <- (map["_links"], ResourceLinkTransformType())
        self.creditCardId <- map["creditCardId"]
        self.userId  <- map["userId"]
        self.isDefault <- map["default"]
        self.created  <- map["createdTs"]
        self.createdEpoch <- map["createdTsEpoch"]
        self.lastModifiedEpoch <- map["lastModifiedTsEpoch"]
        self.state <- map["state"]
        self.cardType <- map["cardType"]
        self.cardMetaData = Mapper<CardMetadata>().map(map["cardMetaData"].currentValue)
    }
}

public class CardMetadata : Mappable
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
    public var issuerLogo:[Image]?

    public var encryptedData:String?
    
    public required init?(_ map: Map)
    {
        
    }
    
    public func mapping(map: Map)
    {
        self.labelColor <- map["labelColor"]
        self.issuerName <- map["issuerName"]
        self.shortDescription <- map["shortDescription"]
        self.longDescription <- map["longDescription"]
        self.contactUrl <- map["contactUrl"]
        self.contactPhone <- map["contactPhone"]
        self.contactEmail <- map["contactEmail"]
        self.termsAndConditionsUrl <- map["termsAndConditionsUrl"]
        self.privacyPolicyUrl <- map["privacyPolicyUrl"]
        self.brandLogo <- (map["brandLogo"], ImageTransformType())
        self.cardBackground <- (map["cardBackground"], ImageTransformType())
        self.cardBackgroundCombined <- (map["cardBackgroundCombined"], ImageTransformType())
        self.coBrandLogo <- (map["coBrandLogo"], ImageTransformType())
        self.icon <- (map["icon"], ImageTransformType())
        self.issuerLogo <- (map["issuerLogo"], ImageTransformType())
    }
}

public class Image : Mappable
{
    public var links: [ResourceLink]?
    public var mimeType:String?
    public var height:Int?
    public var width:Int?
    
    public required init?(_ map: Map)
    {
        
    }
    
    public func mapping(map: Map)
    {
        self.links <- (map["_links"], ResourceLinkTransformType())
        self.mimeType <- map["mimeType"]
        self.height <- map["height"]
        self.width <- map["width"]
    }
}

internal class ImageTransformType : TransformType
{
    typealias Object = [Image]
    typealias JSON = [[String:AnyObject]]
    
    func transformFromJSON(value: AnyObject?) -> [Image]?
    {
        if let images = value as? [[String : AnyObject]]
        {
            var list = [Image]()
            
            for raw in images
            {
                if let image = Mapper<Image>().map(raw)
                {
                    list.append(image)
                }
            }
            
            return list
        }
        
        return nil
    }
    
    func transformToJSON(value:[Image]?) -> [[String:AnyObject]]?
    {
        //TODO: Implement this upon requested
        return nil
    }
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
    public var createdEpoch:CLong?
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
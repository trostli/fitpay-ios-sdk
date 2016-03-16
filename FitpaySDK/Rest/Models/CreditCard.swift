
import Foundation
import ObjectMapper

public class CreditCard : ClientModel, Mappable, SecretApplyable
{
    public var links:[ResourceLink]?
    public var creditCardId:String?
    public var userId:String?
    public var isDefault:Bool?
    public var created:String?
    public var createdEpoch:CLong?
    public var state:String?
    public var cardType:String?
    public var cardMetaData:CardMetadata?    
    public var termsAssetId:String?
    public var termsAssetReferences:[TermsAssetReferences]?
    public var eligibilityExpiration:String?
    public var eligibilityExpirationEpoch:CLong?
    public var deviceRelationships:[DeviceRelationships]?
    internal var encryptedData:String?
    public var targetDeviceId:String?
    public var targetDeviceType:String?
    public var verificationMethods:[VerificationMethod]?
    public var externalTokenReference:String?
    internal var info:CardInfo?
    private static let selfResource = "self"
    private static let acceptTermsResource = "acceptTerms"
    private static let declineTermsResource = "declineTerms"
    private static let deactivateResource = "deactivate"
    private static let reactivateResource = "reactivate"
    private static let makeDefaultResource = "makeDefault"


    private weak var _client:RestClient?
    
    internal var client:RestClient?
    {
        get
        {
            return self._client
        }
        
        set
        {
            self._client = newValue
            
            if let verificationMethods = self.verificationMethods
            {
                for verificationMethod in verificationMethods
                {
                    verificationMethod.client = self.client
                }
            }
            
            if let termsAssetReferences = self.termsAssetReferences
            {
                for termsAssetReference in termsAssetReferences
                {
                    termsAssetReference.client = self.client
                }
            }
            
            
            self.cardMetaData?.client = self.client
            
            
            if let deviceRelationships = self.deviceRelationships
            {
                for deviceRelationship in deviceRelationships
                {
                    deviceRelationship.client = self.client
                }
            }
        }
    }
    
    
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
        self.state <- map["state"]
        self.cardType <- map["cardType"]
        self.cardMetaData = Mapper<CardMetadata>().map(map["cardMetaData"].currentValue)
        self.termsAssetId <- map["termsAssetId"]
        self.termsAssetReferences <- (map["termsAssetReferences"], TermsAssetReferencesTransformType())
        self.eligibilityExpiration <- map["eligibilityExpiration"]
        self.eligibilityExpirationEpoch <- map["eligibilityExpirationEpoch"]
        self.deviceRelationships <- (map["deviceRelationships"], DeviceRelationshipsTransformType())
        self.encryptedData <- map["encryptedData"]
        self.targetDeviceId <- map["targetDeviceId"]
        self.targetDeviceType <- map["targetDeviceType"]
        self.verificationMethods <- (map["verificationMethods"], VerificationMethodTransformType())
        self.externalTokenReference <- map["externalTokenReference"]
    }
    
    func applySecret(secret:Foundation.NSData, expectedKeyId:String?)
    {
        self.info = JWEObject.decrypt(self.encryptedData, expectedKeyId: expectedKeyId, secret: secret)
    }
    
    public func delete(completion:RestClient.DeleteCreditCardHandler)
    {
        let resource = CreditCard.selfResource
        let url = self.links?.url(resource)
        if  let url = url, client = self.client
        {
            client.deleteCreditCard(url, completion: completion)
        }
        else
        {
            completion(error:NSError.clientUrlError(domain:CreditCard.self, code:0, client: client, url: url, resource: resource))
        }
    }
    
    public func update(name name:String?, street1:String?, street2:String?, city:String?, state:String?, postalCode:String?, countryCode:String?, completion:RestClient.UpdateCreditCardHandler)
    {
        let resource = CreditCard.selfResource
        let url = self.links?.url(resource)
        if  let url = url, client = self.client
        {
            client.updateCreditCard(url, name: name, street1: street1, street2: street2, city: city, state: state, postalCode: postalCode, countryCode: countryCode, completion: completion)
        }
        else
        {
            completion(creditCard:nil, error:NSError.clientUrlError(domain:CreditCard.self, code:0, client: client, url: url, resource: resource))
        }
    }
    
    public func acceptTerms(completion:RestClient.AcceptTermsHandler)
    {
        let resource = CreditCard.acceptTermsResource
        let url = self.links?.url(resource)
        if  let url = url, client = self.client
        {
            client.acceptTerms(url, completion: completion)
        }
        else
        {
            completion(pending: false, card: nil, error: NSError.clientUrlError(domain:CreditCard.self, code:0, client: client, url: url, resource: resource))
        }
    }
    
    public func declineTerms(completion:RestClient.DeclineTermsHandler)
    {
        let resource = CreditCard.declineTermsResource
        let url = self.links?.url(resource)
        if  let url = url, client = self.client
        {
            client.declineTerms(url, completion: completion)
        }
        else
        {
            completion(pending: false, card: nil, error: NSError.clientUrlError(domain:CreditCard.self, code:0, client: client, url: url, resource: resource))
        }
    }
    
    public func deactivate(causedBy causedBy:CreditCardInitiator, reason:String, completion:RestClient.DeactivateHandler)
    {
        let resource = CreditCard.deactivateResource
        let url = self.links?.url(resource)
        if  let url = url, client = self.client
        {
            client.deactivate(url, causedBy: causedBy, reason: reason, completion: completion)
        }
        else
        {
            completion(pending: false, creditCard: nil, error: NSError.clientUrlError(domain:CreditCard.self, code:0, client: client, url: url, resource: resource))
        }
    }
    
    public func reactivate(causedBy causedBy:CreditCardInitiator, reason:String, completion:RestClient.ReactivateHandler)
    {
        let resource = CreditCard.reactivateResource
        let url = self.links?.url(resource)
        if  let url = url, client = self.client
        {
            client.reactivate(url, causedBy: causedBy, reason: reason, completion: completion)
        }
        else
        {
            completion(pending: false, creditCard: nil, error: NSError.clientUrlError(domain:CreditCard.self, code:0, client: client, url: url, resource: resource))
        }
    }
    
    public func makeDefault(completion:RestClient.MakeDefaultHandler)
    {
        let resource = CreditCard.makeDefaultResource
        let url = self.links?.url(resource)
        if  let url = url, client = self.client
        {
            client.makeDefault(url, completion: completion)
        }
        else
        {
            completion(pending: false, creditCard: nil, error: NSError.clientUrlError(domain:CreditCard.self, code:0, client: client, url: url, resource: resource))
        }
    }
}

public class CardMetadata : ClientModel, Mappable
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
    private var _client:RestClient?
    internal var client:RestClient?
    {
        get
        {
            return self._client
        }
        
        set
        {
            self._client = newValue
            
            if let brandLogo = self.brandLogo
            {
                for image in brandLogo
                {
                    image.client = self.client
                }
            }
            
            if let cardBackground = self.cardBackground
            {
                for image in cardBackground
                {
                    image.client = self.client
                }
            }
            
            if let cardBackgroundCombined = self.cardBackgroundCombined
            {
                for image in cardBackgroundCombined
                {
                    image.client = self.client
                }
            }
            
            if let coBrandLogo = self.coBrandLogo
            {
                for image in coBrandLogo
                {
                    image.client = self.client
                }
            }
            
            if let icon = self.icon
            {
                for image in icon
                {
                    image.client = self.client
                }
            }
            
            if let issuerLogo = self.issuerLogo
            {
                for image in issuerLogo
                {
                    image.client = self.client
                }
            }
        }
    }
    
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

public class Image : ClientModel, Mappable, AssetRetrivable
{
    public var links: [ResourceLink]?
    public var mimeType:String?
    public var height:Int?
    public var width:Int?
    internal var client:RestClient?
    private static let selfResource = "self"
    
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
    
    public func retrieveAsset(completion: RestClient.AssetsHandler)
    {
        let resource = Image.selfResource
        let url = self.links?.url(resource)
        if  let url = url, client = self.client
        {
            client.assets(url, completion: completion)
        }
        else
        {
            let error = NSError.clientUrlError(domain:CreditCard.self, code:0, client: client, url: url, resource: resource)
            completion(asset: nil, error: error)
        }
    }
}

internal class ImageTransformType : TransformType
{
    typealias Object = [Image]
    typealias JSON = [[String:AnyObject]]
    
    func transformFromJSON(value: AnyObject?) -> [Image]?
    {
        if let images = value as? [[String:AnyObject]]
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
        return nil
    }
}


public class TermsAssetReferences : ClientModel, Mappable, AssetRetrivable
{
    public var links: [ResourceLink]?
    public var mimeType:String?
    internal var client:RestClient?
    private static let selfResource = "self"
    
    public required init?(_ map: Map)
    {
        
    }
    
    public func mapping(map: Map)
    {
        self.links <- (map["_links"], ResourceLinkTransformType())
        self.mimeType <- map["mimeType"]
    }
    
    public func retrieveAsset(completion: RestClient.AssetsHandler)
    {
        let resource = TermsAssetReferences.selfResource
        let url = self.links?.url(resource)
        if  let url = url, client = self.client
        {
            client.assets(url, completion: completion)
        }
        else
        {
            let error = NSError.clientUrlError(domain:CreditCard.self, code:0, client: client, url: url, resource: resource)
            completion(asset: nil, error: error)
        }
    }
}

internal class TermsAssetReferencesTransformType : TransformType
{
    typealias Object = [TermsAssetReferences]
    typealias JSON = [[String:AnyObject]]
    
    func transformFromJSON(value: AnyObject?) -> [TermsAssetReferences]?
    {
        if let items = value as? [[String:AnyObject]]
        {
            var list = [TermsAssetReferences]()
            
            for raw in items
            {
                if let item = Mapper<TermsAssetReferences>().map(raw)
                {
                    list.append(item)
                }
            }
            
            return list
        }
        
        return nil
    }
    
    func transformToJSON(value:[TermsAssetReferences]?) -> [[String:AnyObject]]?
    {
        return nil
    }
}

public class DeviceRelationships : ClientModel, Mappable
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
    
    internal var client:RestClient?
    
    public required init?(_ map: Map)
    {
        
    }
    
    public func mapping(map: Map)
    {
        self.deviceType <- map["deviceType"]
        self.links <- (map["_links"], ResourceLinkTransformType())
        self.deviceIdentifier <- map["deviceIdentifier"]
        self.manufacturerName <- map["manufacturerName"]
        self.deviceName <- map["deviceName"]
        self.serialNumber <- map["serialNumber"]
        self.modelNumber <- map["modelNumber"]
        self.hardwareRevision <- map["hardwareRevision"]
        self.firmwareRevision <- map["firmwareRevision"]
        self.softwareRevision <- map["softwareRevision"]
        self.created <- map["createdTs"]
        self.createdEpoch <- map["createdTsEpoch"]
        self.osName <- map["osName"]
        self.systemId <- map["systemId"]
    }
}

internal class DeviceRelationshipsTransformType : TransformType
{
    typealias Object = [DeviceRelationships]
    typealias JSON = [[String:AnyObject]]
    
    func transformFromJSON(value: AnyObject?) -> [DeviceRelationships]?
    {
        if let items = value as? [[String:AnyObject]]
        {
            var list = [DeviceRelationships]()
            
            for raw in items
            {
                if let item = Mapper<DeviceRelationships>().map(raw)
                {
                    list.append(item)
                }
            }
            
            return list
        }
        
        return nil
    }
    
    func transformToJSON(value:[DeviceRelationships]?) -> [[String:AnyObject]]?
    {
        return nil
    }
}


internal class CardInfo : Mappable
{
    var pan:String?
    var expMonth:Int?
    var expYear:Int?
    var cvv:String?
    var creditCardId:String?
    var name:String?
    var address:Address?
    
    internal required init?(_ map: Map)
    {
        
    }
    
    internal func mapping(map: Map)
    {
        self.pan <- map["pan"]
        self.creditCardId <- map["creditCardId"]
        self.expMonth <- map["expMonth"]
        self.expYear <- map["expYear"]
        self.cvv <- map["cvv"]
        self.name <- map["name"]
        self.address = Mapper<Address>().map(map["address"].currentValue)
        self.name <- map["name"]
    }
}
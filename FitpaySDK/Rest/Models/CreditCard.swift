
import Foundation
import ObjectMapper

public enum TokenizationState : String
{
    case NEW,
    NOT_ELIGIBLE,
    ELIGIBLE,
    DECLINED_TERMS_AND_CONDITIONS,
    PENDING_ACTIVE,
    PENDING_VERIFICATION,
    DELETED,
    ACTIVE,
    DEACTIVATED,
    ERROR,
    DECLINED
}

public class CreditCard : NSObject, ClientModel, Mappable, SecretApplyable
{
    internal var links:[ResourceLink]?
    internal var encryptedData:String?

    public var creditCardId:String?
    public var userId:String?
    public var isDefault:Bool?
    public var created:String?
    public var createdEpoch:NSTimeInterval?
    public var state:TokenizationState?
    public var cardType:String?
    public var cardMetaData:CardMetadata?
    public var termsAssetId:String?
    public var termsAssetReferences:[TermsAssetReferences]?
    public var eligibilityExpiration:String?
    public var eligibilityExpirationEpoch:NSTimeInterval?
    public var deviceRelationships:[DeviceRelationships]?
    public var targetDeviceId:String?
    public var targetDeviceType:String?
    public var verificationMethods:[VerificationMethod]?
    public var externalTokenReference:String?
    public var info:CardInfo?
    public var pan:String?
    public var expMonth:Int?
    public var expYear:Int?
    public var cvv:String?
    public var name:String?
    public var address:Address?
    public var topOfWalletAPDUCommands:[APDUCommand]?

    private static let selfResource = "self"
    private static let acceptTermsResource = "acceptTerms"
    private static let declineTermsResource = "declineTerms"
    private static let deactivateResource = "deactivate"
    private static let reactivateResource = "reactivate"
    private static let makeDefaultResource = "makeDefault"
    private static let transactionsResource = "transactions"

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
            
            if let deviceRelationships = self.deviceRelationships
            {
                for deviceRelationship in deviceRelationships
                {
                    deviceRelationship.client = self.client
                }
            }
            
            self.cardMetaData?.client = self.client
        }
    }
    
    public var acceptTermsAvailable:Bool
    {
        return self.links?.url(CreditCard.acceptTermsResource) != nil
    }
    
    public var declineTermsAvailable:Bool
    {
        return self.links?.url(CreditCard.declineTermsResource) != nil
    }
    
    public var deactivateAvailable:Bool
    {
        return self.links?.url(CreditCard.deactivateResource) != nil
    }
    
    public var reactivateAvailable:Bool
    {
        return self.links?.url(CreditCard.reactivateResource) != nil
    }
    
    public var makeDefaultAvailable:Bool
    {
        return self.links?.url(CreditCard.makeDefaultResource) != nil
    }
    
    public var listTransactionsAvailable:Bool
    {
        return self.links?.url(CreditCard.transactionsResource) != nil
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
        self.createdEpoch <- (map["createdTsEpoch"], NSTimeIntervalTransform())
        self.state <- map["state"]
        self.cardType <- map["cardType"]
        self.cardMetaData = Mapper<CardMetadata>().map(map["cardMetaData"].currentValue)
        self.termsAssetId <- map["termsAssetId"]
        self.termsAssetReferences <- (map["termsAssetReferences"], TermsAssetReferencesTransformType())
        self.eligibilityExpiration <- map["eligibilityExpiration"]
        self.eligibilityExpirationEpoch <- (map["eligibilityExpirationEpoch"], NSTimeIntervalTransform())
        self.deviceRelationships <- (map["deviceRelationships"], DeviceRelationshipsTransformType())
        self.encryptedData <- map["encryptedData"]
        self.targetDeviceId <- map["targetDeviceId"]
        self.targetDeviceType <- map["targetDeviceType"]
        self.verificationMethods <- (map["verificationMethods"], VerificationMethodTransformType())
        self.externalTokenReference <- map["externalTokenReference"]
        self.pan <- map["pan"]
        self.creditCardId <- map["creditCardId"]
        self.expMonth <- map["expMonth"]
        self.expYear <- map["expYear"]
        self.cvv <- map["cvv"]
        self.name <- map["name"]
        self.address = Mapper<Address>().map(map["address"].currentValue)
        self.name <- map["name"]
        self.topOfWalletAPDUCommands <- map["offlineSeActions.topOfWallet.apduCommands"]
    }
    
    func applySecret(secret:Foundation.NSData, expectedKeyId:String?)
    {
        self.info = JWEObject.decrypt(self.encryptedData, expectedKeyId: expectedKeyId, secret: secret)
    }

    /**
     Get the the credit card. This is useful for updated the card with the most recent data and some properties change asynchronously

     - parameter completion:   CreditCardHandler closure
     */
    @objc public func getCreditCard(completion:RestClient.CreditCardHandler) {
        let resource = CreditCard.selfResource
        let url = self.links?.url(resource)

        if  let url = url, client = self.client {
            client.retrieveCreditCard(url, completion: completion)
        } else {
            completion(creditCard: nil, error: NSError.clientUrlError(domain:CreditCard.self, code:0, client: client, url: url, resource: resource))
        }
    }

    /**
     Delete a single credit card from a user's profile. If you delete a card that is currently the default source, then the most recently added source will become the new default.
     
     - parameter completion:   DeleteCreditCardHandler closure
     */
    @objc public func deleteCreditCard(completion:RestClient.DeleteCreditCardHandler)
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
    
    /**
     Update the details of an existing credit card
     
     - parameter name:         name
     - parameter street1:      address
     - parameter street2:      address
     - parameter city:         city
     - parameter state:        state
     - parameter postalCode:   postal code
     - parameter countryCode:  country code
     - parameter completion:   UpdateCreditCardHandler closure
     */
    @objc public func update(name name:String?, street1:String?, street2:String?, city:String?, state:String?, postalCode:String?, countryCode:String?, completion:RestClient.UpdateCreditCardHandler)
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
    
    /**
     Indicates a user has accepted the terms and conditions presented when the credit card was first added to the user's profile
     
     - parameter completion:   AcceptTermsHandler closure
     */
    @objc public func acceptTerms(completion:RestClient.AcceptTermsHandler)
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
    
    /**
     Indicates a user has declined the terms and conditions. Once declined the credit card will be in a final state, no other actions may be taken
     
     - parameter completion:   DeclineTermsHandler closure
     */
    @objc public func declineTerms(completion:RestClient.DeclineTermsHandler)
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
    
    /**
     Transition the credit card into a deactived state so that it may not be utilized for payment. This link will only be available for qualified credit cards that are currently in an active state.
     
     - parameter causedBy:     deactivation initiator
     - parameter reason:       deactivation reason
     - parameter completion:   DeactivateHandler closure
     */
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
    
    /**
     Transition the credit card into an active state where it can be utilized for payment. This link will only be available for qualified credit cards that are currently in a deactivated state.
     
     - parameter causedBy:     reactivation initiator
     - parameter reason:       reactivation reason
     - parameter completion:   ReactivateHandler closure
     */
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
    
    /**
     Mark the credit card as the default payment instrument. If another card is currently marked as the default, the default will automatically transition to the indicated credit card
     
     - parameter completion:   MakeDefaultHandler closure
     */
     @objc public func makeDefault(completion:RestClient.MakeDefaultHandler)
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
    
    /**
     Provides a transaction history (if available) for the user, results are limited by provider.
     
     - parameter limit:      max number of profiles per page
     - parameter offset:     start index position for list of entities returned
     - parameter completion: TransactionsHandler closure
     */
    public func listTransactions(limit limit:Int, offset:Int, completion:RestClient.TransactionsHandler)
    {
        let resource = CreditCard.transactionsResource
        let url = self.links?.url(resource)
        if  let url = url, client = self.client
        {
            client.transactions(url, limit: limit, offset: offset, completion: completion)
        }
        else
        {
            completion(result: nil, error: NSError.clientUrlError(domain:CreditCard.self, code:0, client: client, url: url, resource: resource))
        }
    }
}

public class CardMetadata : NSObject, ClientModel, Mappable
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

public class Image : NSObject, ClientModel, Mappable, AssetRetrivable
{
    internal var links: [ResourceLink]?
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
            let error = NSError.clientUrlError(domain:Image.self, code:0, client: client, url: url, resource: resource)
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


public class TermsAssetReferences : NSObject, ClientModel, Mappable, AssetRetrivable
{
    internal var links: [ResourceLink]?
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
    
    @objc public func retrieveAsset(completion: RestClient.AssetsHandler)
    {
        let resource = TermsAssetReferences.selfResource
        let url = self.links?.url(resource)
        if  let url = url, client = self.client
        {
            client.assets(url, completion: completion)
        }
        else
        {
            let error = NSError.clientUrlError(domain:TermsAssetReferences.self, code:0, client: client, url: url, resource: resource)
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

public class DeviceRelationships : NSObject, ClientModel, Mappable
{
    public var deviceType:String?
    internal var links: [ResourceLink]?
    public var deviceIdentifier:String?
    public var manufacturerName:String?
    public var deviceName:String?
    public var serialNumber:String?
    public var modelNumber:String?
    public var hardwareRevision:String?
    public var firmwareRevision:String?
    public var softwareRevision:String?
    public var created:String?
    public var createdEpoch:NSTimeInterval?
    public var osName:String?
    public var systemId:String?
    
    private static let selfResource = "self"
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
        self.createdEpoch <- (map["createdTsEpoch"], NSTimeIntervalTransform())
        self.osName <- map["osName"]
        self.systemId <- map["systemId"]
    }
    
    @objc func relationship(completion:RestClient.RelationshipHandler) {
        let resource = DeviceRelationships.selfResource
        let url = self.links?.url(resource)
        if let url = url, client = self.client
        {
            client.relationship(url, completion: completion)
        }
        else
        {
            completion(relationship: nil, error: NSError.clientUrlError(domain:DeviceRelationships.self, code:0, client: client, url: url, resource: resource))
        }
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


public class CardInfo : Mappable
{
    public var pan:String?
    public var expMonth:Int?
    public var expYear:Int?
    public var cvv:String?
    public var creditCardId:String?
    public var name:String?
    public var address:Address?
    
    public required init?(_ map: Map)
    {
        
    }
    
    public func mapping(map: Map)
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

/**
 Identifies the party initiating the deactivation/reactivation request
 
 - CARDHOLDER: card holder
 - ISSUER:     issuer
 */
public enum CreditCardInitiator: String
{
    case CARDHOLDER
    case ISSUER
}
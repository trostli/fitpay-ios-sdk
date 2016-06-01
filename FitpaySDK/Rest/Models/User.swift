
import ObjectMapper

public class User : NSObject, ClientModel, Mappable, SecretApplyable
{
    internal var links:[ResourceLink]?
    public var id:String?
    public var created:String?
    public var createdEpoch:NSTimeInterval? //iOS represents epoch as a double, but really represents it as an NSTimeInterval. Java is a long.
    public var lastModified:String?
    public var lastModifiedEpoch:CLong?
    internal var encryptedData:String?
    internal var info:UserInfo?
    private static let creditCardsResource = "creditCards"
    private static let devicesResource = "devices"
    private static let selfResource = "self"
    
    public var firstName:String?
    {
        return self.info?.firstName
    }
    
    public var lastName:String?
    {
        return self.info?.lastName
    }
    
    public var birthDate:String?
    {
        return self.info?.birthDate
    }
    
    public var email:String?
    {
        return self.info?.email
    }
    
    public var listCreditCardsAvailable:Bool
    {
        return self.links?.url(User.creditCardsResource) != nil
    }
    
    public var listDevicesAvailable:Bool
    {
        return self.links?.url(User.devicesResource) != nil
    }
    
    internal weak var client:RestClient?

    
    public required init?(_ map: Map)
    {
        
    }
    
    public func mapping(map: Map)
    {
        links <- (map["_links"], ResourceLinkTransformType())
        id <- map["id"]
        created <- map["createdTs"]
        createdEpoch <- map["createdTsEpoch"]
        lastModified <- map["lastModifiedTs"]
        lastModifiedEpoch <- map["lastModifiedTsEpoch"]
        encryptedData <- map["encryptedData"]
    }
    
    internal func applySecret(secret:NSData, expectedKeyId:String?)
    {
        self.info = JWEObject.decrypt(self.encryptedData, expectedKeyId: expectedKeyId, secret: secret)
    }
    
    /**
     Add a single credit card to a user's profile. If the card owner has no default card, then the new card will become the default.
     
     - parameter pan:        pan
     - parameter expMonth:   expiration month
     - parameter expYear:    expiration year
     - parameter cvv:        cvv code
     - parameter name:       user name
     - parameter street1:    address
     - parameter street2:    address
     - parameter street3:    street name
     - parameter city:       address
     - parameter state:      state
     - parameter postalCode: postal code
     - parameter country:    country
     - parameter completion: CreateCreditCardHandler closure
     */
    @objc public func createCreditCard(pan pan:String, expMonth:Int, expYear:Int, cvv:String, name:String,
        street1:String, street2:String, street3:String, city:String, state:String, postalCode:String, country:String,
        completion:RestClient.CreateCreditCardHandler)
    {
        let resource = User.creditCardsResource
        let url = self.links?.url(resource)
        if  let url = url, client = self.client
        {
            client.createCreditCard(url, pan: pan, expMonth: expMonth, expYear: expYear, cvv: cvv, name: name, street1: street1, street2: street2, street3: street3, city: city, state: state, postalCode: postalCode, country: country, completion: completion)
        }
        else
        {
            completion(creditCard: nil, error: NSError.clientUrlError(domain:User.self, code:0, client: client, url: url, resource: resource))
        }

    }
    
    /**
     Retrieves the details of an existing credit card. You need only supply the uniqueidentifier that was returned upon creation.
     
     - parameter excludeState: Exclude all credit cards in the specified state. If you desire to specify multiple excludeState values, then repeat this query parameter multiple times.
     - parameter limit:        max number of profiles per page
     - parameter offset:       start index position for list of entities returned
     - parameter completion:   CreditCardsHandler closure
     */
    public func listCreditCards(excludeState excludeState:[String], limit:Int, offset:Int, completion:RestClient.CreditCardsHandler)
    {
        let resource = User.creditCardsResource
        let url = self.links?.url(resource)
        if  let url = url, client = self.client
        {
            client.creditCards(url, excludeState: excludeState, limit: limit, offset: offset, completion: completion)
        }
        else
        {
            completion(result:nil, error: NSError.clientUrlError(domain:User.self, code:0, client: client, url: url, resource: resource))
        }
    }
    
    /**
     For a single user, retrieve a pagable collection of devices in their profile
     
     - parameter limit:      max number of profiles per page
     - parameter offset:     start index position for list of entities returned
     - parameter completion: DevicesHandler closure
     */
    public func listDevices(limit limit:Int, offset:Int, completion:RestClient.DevicesHandler)
    {
        let resource = User.devicesResource
        let url = self.links?.url(resource)
        if  let url = url, client = self.client
        {
            client.devices(url, limit: limit, offset: offset, completion: completion)
        }
        else
        {
            completion(result:nil, error: NSError.clientUrlError(domain:User.self, code:0, client: client, url: url, resource: resource))
        }
    }
    
    /**
     For a single user, create a new device in their profile
     
     - parameter deviceType:       device type
     - parameter manufacturerName: manufacturer name
     - parameter deviceName:       device name
     - parameter serialNumber:     serial number
     - parameter modelNumber:      model number
     - parameter hardwareRevision: hardware revision
     - parameter firmwareRevision: firmware revision
     - parameter softwareRevision: software revision
     - parameter systemId:         system id
     - parameter osName:           os name
     - parameter licenseKey:       license key
     - parameter bdAddress:        bd address //TODO: provide better description
     - parameter secureElementId:  secure element id
     - parameter pairing:          pairing date [MM-DD-YYYY]
     - parameter completion:       CreateNewDeviceHandler closure
     */
    @objc public func createNewDevice(deviceType:String, manufacturerName:String, deviceName:String,
        serialNumber:String, modelNumber:String, hardwareRevision:String, firmwareRevision:String,
        softwareRevision:String, systemId:String, osName:String, licenseKey:String, bdAddress:String,
        secureElementId:String, pairing:String, completion:RestClient.CreateNewDeviceHandler)
    {
        let resource = User.devicesResource
        let url = self.links?.url(resource)
        if  let url = url, client = self.client
        {
            client.createNewDevice(url, deviceType: deviceType, manufacturerName: manufacturerName, deviceName: deviceName, serialNumber: serialNumber, modelNumber: modelNumber, hardwareRevision: hardwareRevision, firmwareRevision: firmwareRevision, softwareRevision: softwareRevision, systemId: systemId, osName: osName, licenseKey: licenseKey, bdAddress: bdAddress, secureElementId: secureElementId, pairing: pairing, completion: completion)
        }
        else
        {
            completion(device:nil, error: NSError.clientUrlError(domain:User.self, code:0, client: client, url: url, resource: resource))
        }
    }
    
    @objc public func createRelationship(creditCardId creditCardId:String, deviceId:String, completion:RestClient.CreateRelationshipHandler)
    {
        let resource = User.selfResource
        let url = self.links?.url(resource)
        if  let url = url, client = self.client
        {
            client.createRelationship(url, creditCardId: creditCardId, deviceId: deviceId, completion: completion)
        }
        else
        {
            completion(relationship: nil, error: NSError.clientUrlError(domain:User.self, code:0, client: client, url: url, resource: resource))
        }
    }
    
    @objc public func deleteUser(completion:RestClient.DeleteUserHandler)
    {
        let resource = User.selfResource
        let url = self.links?.url(resource)
        if  let url = url, client = self.client
        {
            client.deleteUser(url, completion: completion)
        }
        else
        {
            completion(error: NSError.clientUrlError(domain:User.self, code:0, client: client, url: url, resource: resource))
        }
    }
    
    @objc public func updateUser(firstName firstName:String?, lastName:String?, birthDate:String?, originAccountCreated:String?, termsAccepted:String?, termsVersion:String?, completion:RestClient.UpdateUserHandler)
    {
        let resource = User.selfResource
        let url = self.links?.url(resource)
        if  let url = url, client = self.client
        {
            client.updateUser(url, firstName: firstName, lastName: lastName, birthDate: birthDate, originAccountCreated: originAccountCreated, termsAccepted: termsAccepted, termsVersion: termsVersion, completion: completion)
        }
        else
        {
            completion(user:nil, error: NSError.clientUrlError(domain:User.self, code:0, client: client, url: url, resource: resource))
        }
    }
}

internal class UserInfo : Mappable
{
    var firstName:String?
    var lastName:String?
    var birthDate:String?
    var email:String?
    
    required init?(_ map: Map)
    {

    }
    
    func mapping(map: Map)
    {
        self.firstName <- map["firstName"]
        self.lastName <- map["lastName"]
        self.birthDate <- map["birthDate"]
        self.email <- map["email"]
    }
}

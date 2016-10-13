
import ObjectMapper

open class User : NSObject, ClientModel, Mappable, SecretApplyable
{
    internal var links:[ResourceLink]?
    open var id:String?
    open var created:String?
    open var createdEpoch:TimeInterval? //iOS represents epoch as a double, but really represents it as an NSTimeInterval. Java is a long.
    open var lastModified:String?
    open var lastModifiedEpoch:TimeInterval?
    internal var encryptedData:String?
    internal var info:UserInfo?
    fileprivate static let creditCardsResource = "creditCards"
    fileprivate static let devicesResource = "devices"
    fileprivate static let selfResource = "self"
    
    open var firstName:String?
    {
        return self.info?.firstName
    }
    
    open var lastName:String?
    {
        return self.info?.lastName
    }
    
    open var birthDate:String?
    {
        return self.info?.birthDate
    }
    
    open var email:String?
    {
        return self.info?.email
    }
    
    open var listCreditCardsAvailable:Bool
    {
        return self.links?.url(User.creditCardsResource) != nil
    }
    
    open var listDevicesAvailable:Bool
    {
        return self.links?.url(User.devicesResource) != nil
    }
    
    internal weak var client:RestClient?

    
    public required init?(map: Map)
    {
        
    }
    
    open func mapping(map: Map)
    {
        links <- (map["_links"], ResourceLinkTransformType())
        id <- map["id"]
        created <- map["createdTs"]
        createdEpoch <- (map["createdTsEpoch"], NSTimeIntervalTransform())
        lastModified <- map["lastModifiedTs"]
        lastModifiedEpoch <- (map["lastModifiedTsEpoch"], NSTimeIntervalTransform())
        encryptedData <- map["encryptedData"]
    }
    
    internal func applySecret(_ secret:Data, expectedKeyId:String?)
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
    @objc open func createCreditCard(pan:String, expMonth:Int, expYear:Int, cvv:String, name:String,
        street1:String, street2:String, street3:String, city:String, state:String, postalCode:String, country:String,
        completion:@escaping RestClient.CreateCreditCardHandler)
    {
        let resource = User.creditCardsResource
        let url = self.links?.url(resource)
        if  let url = url, let client = self.client
        {
            client.createCreditCard(url, pan: pan, expMonth: expMonth, expYear: expYear, cvv: cvv, name: name, street1: street1, street2: street2, street3: street3, city: city, state: state, postalCode: postalCode, country: country, completion: completion)
        }
        else
        {
            completion(nil, NSError.clientUrlError(domain:User.self, code:0, client: client, url: url, resource: resource))
        }

    }
    
    /**
     Retrieves the details of an existing credit card. You need only supply the uniqueidentifier that was returned upon creation.
     
     - parameter excludeState: Exclude all credit cards in the specified state. If you desire to specify multiple excludeState values, then repeat this query parameter multiple times.
     - parameter limit:        max number of profiles per page
     - parameter offset:       start index position for list of entities returned
     - parameter completion:   CreditCardsHandler closure
     */
    open func listCreditCards(excludeState:[String], limit:Int, offset:Int, completion:@escaping RestClient.CreditCardsHandler)
    {
        let resource = User.creditCardsResource
        let url = self.links?.url(resource)
        if  let url = url, let client = self.client
        {
            client.creditCards(url, excludeState: excludeState, limit: limit, offset: offset, completion: completion)
        }
        else
        {
            completion(nil, NSError.clientUrlError(domain:User.self, code:0, client: client, url: url, resource: resource))
        }
    }
    
    /**
     For a single user, retrieve a pagable collection of devices in their profile
     
     - parameter limit:      max number of profiles per page
     - parameter offset:     start index position for list of entities returned
     - parameter completion: DevicesHandler closure
     */
    open func listDevices(limit:Int, offset:Int, completion:@escaping RestClient.DevicesHandler)
    {
        let resource = User.devicesResource
        let url = self.links?.url(resource)
        if  let url = url, let client = self.client
        {
            client.devices(url, limit: limit, offset: offset, completion: completion)
        }
        else
        {
            completion(nil, NSError.clientUrlError(domain:User.self, code:0, client: client, url: url, resource: resource))
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
    @objc open func createNewDevice(_ deviceType:String, manufacturerName:String, deviceName:String,
        serialNumber:String, modelNumber:String, hardwareRevision:String, firmwareRevision:String,
        softwareRevision:String, systemId:String, osName:String, licenseKey:String, bdAddress:String,
        secureElementId:String, pairing:String, completion:@escaping RestClient.CreateNewDeviceHandler)
    {
        let resource = User.devicesResource
        let url = self.links?.url(resource)
        if  let url = url, let client = self.client
        {
            client.createNewDevice(url, deviceType: deviceType, manufacturerName: manufacturerName, deviceName: deviceName, serialNumber: serialNumber, modelNumber: modelNumber, hardwareRevision: hardwareRevision, firmwareRevision: firmwareRevision, softwareRevision: softwareRevision, systemId: systemId, osName: osName, licenseKey: licenseKey, bdAddress: bdAddress, secureElementId: secureElementId, pairing: pairing, completion: completion)
        }
        else
        {
            completion(nil, NSError.clientUrlError(domain:User.self, code:0, client: client, url: url, resource: resource))
        }
    }
    
    @objc open func createRelationship(creditCardId:String, deviceId:String, completion:@escaping RestClient.CreateRelationshipHandler)
    {
        let resource = User.selfResource
        let url = self.links?.url(resource)
        if  let url = url, let client = self.client
        {
            client.createRelationship(url, creditCardId: creditCardId, deviceId: deviceId, completion: completion)
        }
        else
        {
            completion(nil, NSError.clientUrlError(domain:User.self, code:0, client: client, url: url, resource: resource))
        }
    }
    
    @objc open func deleteUser(_ completion:@escaping RestClient.DeleteUserHandler)
    {
        let resource = User.selfResource
        let url = self.links?.url(resource)
        if  let url = url, let client = self.client
        {
            client.deleteUser(url, completion: completion)
        }
        else
        {
            completion(NSError.clientUrlError(domain:User.self, code:0, client: client, url: url, resource: resource))
        }
    }
    
    @objc open func updateUser(firstName:String?, lastName:String?, birthDate:String?, originAccountCreated:String?, termsAccepted:String?, termsVersion:String?, completion:@escaping RestClient.UpdateUserHandler)
    {
        let resource = User.selfResource
        let url = self.links?.url(resource)
        if  let url = url, let client = self.client
        {
            client.updateUser(url, firstName: firstName, lastName: lastName, birthDate: birthDate, originAccountCreated: originAccountCreated, termsAccepted: termsAccepted, termsVersion: termsVersion, completion: completion)
        }
        else
        {
            completion(nil, NSError.clientUrlError(domain:User.self, code:0, client: client, url: url, resource: resource))
        }
    }
}

internal class UserInfo : Mappable
{
    var firstName:String?
    var lastName:String?
    var birthDate:String?
    var email:String?
    
    required init?(map: Map)
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

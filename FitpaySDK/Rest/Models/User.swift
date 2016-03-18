
import ObjectMapper

public class User : ClientModel, Mappable, SecretApplyable
{
    internal var links:[ResourceLink]?
    public var id:String?
    public var created:String?
    public var createdEpoch:CLong?
    public var lastModified:String?
    public var lastModifiedEpoch:CLong?
    internal var encryptedData:String?
    internal var info:UserInfo?
    private static let creditCardsResource = "creditCards"
    private static let devicesResource = "devices"
    
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
    
    public func createCreditCard(pan pan:String, expMonth:Int, expYear:Int, cvv:String, name:String,
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
    
    public func listDevices(limit:Int, offset:Int, completion:RestClient.DevicesHandler)
    {
        let resource = User.devicesResource
        let url = self.links?.url(resource)
        if  let url = url, client = self.client
        {
            client.devices(url, limit: limit, offset: offset, completion: completion)
        }
        else
        {
            completion(devices:nil, error: NSError.clientUrlError(domain:User.self, code:0, client: client, url: url, resource: resource))
        }
    }
    
    public func createNewDevice(deviceType:String, manufacturerName:String, deviceName:String,
        serialNumber:String, modelNumber:String, hardwareRevision:String, firmwareRevision:String,
        softwareRevision:String, systemId:String, osName:String, licenseKey:String, bdAddress:String,
        secureElementId:String, pairing:String, completion:RestClient.CreateNewDeviceHandler)
    {
        let resource = User.devicesResource
        let url = self.links?.url(resource)
        if  let url = url, client = self.client
        {
            client.createNewDevice(url, deviceType: deviceType, manufacturerName: manufacturerName, deviceName: deviceName, serialNumber: serialNumber, modelNumber: modelNumber, hardwareRevision: hardwareRevision, firmwareRevision: firmwareRevision, softwareRevision: secureElementId, systemId: systemId, osName: osName, licenseKey: licenseKey, bdAddress: bdAddress, secureElementId: secureElementId, pairing: pairing, completion: completion)
        }
        else
        {
            completion(device:nil, error: NSError.clientUrlError(domain:User.self, code:0, client: client, url: url, resource: resource))
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

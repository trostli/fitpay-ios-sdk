
import ObjectMapper

public class DeviceInfo : NSObject, ClientModel, Mappable, SecretApplyable
{
    internal var links:[ResourceLink]?
    public var deviceIdentifier:String?
    public var deviceName:String?
    public var deviceType:String?
    public var manufacturerName:String?
    public var serialNumber:String?
    public var modelNumber:String?
    public var hardwareRevision:String?
    public var firmwareRevision:String?
    public var softwareRevision:String?
    public var notificationToken:String?
    public var createdEpoch:NSTimeInterval?
    public var created:String?
    public var osName:String?
    public var systemId:String?
    public var cardRelationships:[CardRelationship]?
    public var licenseKey:String?
    public var bdAddress:String?
    public var pairing:String?
    public var secureElementId:String?
    private static let userResource = "user"
    private static let commitsResource = "commits"
    private static let selfResource = "self"
    
    private weak var _client:RestClient?

    // Extra metadata specific for a particural type of device
    public var metadata:[String : AnyObject]?
    
    public var userAvailable:Bool
    {
        return self.links?.url(DeviceInfo.userResource) != nil
    }
    
    public var listCommitsAvailable:Bool
    {
        return self.links?.url(DeviceInfo.commitsResource) != nil
    }
    
    internal var client:RestClient?
    {
        get
        {
            return self._client
        }
        set
        {
            self._client = newValue
            
            if let cardRelationships = self.cardRelationships
            {
                for cardRelationship in cardRelationships
                {
                    cardRelationship.client = self.client
                }
            }
        }
    }
    
    override public init() {
        
    }
    
    public required init?(_ map: Map)
    {
        
    }
    
    public func mapping(map: Map)
    {
        links <- (map["_links"], ResourceLinkTransformType())
        created <- map["createdTs"]
        createdEpoch <- (map["createdTsEpoch"], NSTimeIntervalTransform())
        deviceIdentifier <- map["deviceIdentifier"]
        deviceName <- map["deviceName"]
        deviceType <- map["deviceType"]
        manufacturerName <- map["manufacturerName"]
        serialNumber <- map["serialNumber"]
        modelNumber <- map["modelNumber"]
        hardwareRevision <- map["hardwareRevision"]
        firmwareRevision <- map["firmwareRevision"]
        softwareRevision <- map["softwareRevision"]
        notificationToken <- map["notificationToken"]
        osName <- map["osName"]
        systemId <- map["systemId"]
        licenseKey <- map["licenseKey"]
        bdAddress <- map["bdAddress"]
        pairing <- map["pairing"]
        if let secureElement = map["secureElement"].currentValue as? [String:String] {
            secureElementId = secureElement["secureElementId"]
        }  else {
            secureElementId <- map["secureElementId"]
        }
        
        if let cardRelationships = map["cardRelationships"].currentValue as? [AnyObject] {
            if cardRelationships.count > 0 {
                self.cardRelationships = [CardRelationship]()
                
                for itrObj in cardRelationships {
                    if let parsedObj = Mapper<CardRelationship>().map(itrObj) {
                        self.cardRelationships!.append(parsedObj)
                    }
                }
            }
        }
        
        metadata = map.JSONDictionary
    }
    
    func applySecret(secret:NSData, expectedKeyId:String?) {
        if let cardRelationships = self.cardRelationships {
            for modelObject in cardRelationships {
                modelObject.applySecret(secret, expectedKeyId: expectedKeyId)
            }
        }
    }
    
    var shortRTMRepersentation:String? {
        
        var dic : [String:AnyObject] = [:]
        
        if let deviceType = self.deviceType {
            dic["deviceType"] = deviceType
        }
        
        if let deviceName = self.deviceName {
            dic["deviceName"] = deviceName
        }
        
        if let manufacturerName = self.manufacturerName {
            dic["manufacturerName"] = manufacturerName
        }
        
        if let modelNumber = self.modelNumber {
            dic["modelNumber"] = modelNumber
        }
        
        if let hardwareRevision = self.hardwareRevision {
            dic["hardwareRevision"] = hardwareRevision
        }
        
        if let firmwareRevision = self.firmwareRevision {
            dic["firmwareRevision"] = firmwareRevision
        }
        
        if let softwareRevision = self.softwareRevision {
            dic["softwareRevision"] = softwareRevision
        }
        
        if let systemId = self.systemId {
            dic["systemId"] = systemId
        }
        
        if let osName = self.osName {
            dic["osName"] = osName
        }
        
        if let licenseKey = self.licenseKey {
            dic["licenseKey"] = licenseKey
        }
        
        if let bdAddress = self.bdAddress {
            dic["bdAddress"] = bdAddress
        }
        
        if let secureElementId = self.secureElementId {
            dic["secureElement"] = ["secureElementId" : secureElementId]
        }
        
        guard let jsonData = try? NSJSONSerialization.dataWithJSONObject(dic, options: NSJSONWritingOptions(rawValue: 0)) else {
            return nil
        }
        
        return String(data: jsonData, encoding: NSUTF8StringEncoding)
    }
    
    /**
     Delete a single device
     
     - parameter completion: DeleteDeviceHandler closure
     */
    @objc public func deleteDeviceInfo(completion:RestClient.DeleteDeviceHandler) {
        let resource = DeviceInfo.selfResource
        let url = self.links?.url(resource)
        if  let url = url, client = self.client
        {
            client.deleteDevice(url, completion: completion)
        }
        else
        {
            completion(error: NSError.clientUrlError(domain:DeviceInfo.self, code:0, client: client, url: url, resource: resource))
        }
    }
    
    /**
     Update the details of an existing device
     (For optional? parameters use nil if field doesn't need to be updated) //TODO: consider adding default nil value

     - parameter firmwareRevision?: firmware revision
     - parameter softwareRevision?: software revision
     - parameter completion:        UpdateDeviceHandler closure
     */
    @objc public func update(firmwareRevision:String?, softwareRevision:String?, notifcationToken: String?, completion:RestClient.UpdateDeviceHandler) {
        let resource = DeviceInfo.selfResource
        let url = self.links?.url(resource)
        if  let url = url, client = self.client
        {
            client.updateDevice(url, firmwareRevision: firmwareRevision, softwareRevision: softwareRevision, notifcationToken: notifcationToken, completion: completion)
        }
        else
        {
            completion(device: nil, error: NSError.clientUrlError(domain:DeviceInfo.self, code:0, client: client, url: url, resource: resource))
        }
    }
    
    /**
     Retrieves a collection of all events that should be committed to this device
     
     - parameter commitsAfter: the last commit successfully applied. Query will return all subsequent commits which need to be applied.
     - parameter limit:        max number of profiles per page
     - parameter offset:       start index position for list of entities returned
     - parameter completion:   CommitsHandler closure
     */
    public func listCommits(commitsAfter commitsAfter:String?, limit:Int, offset:Int, completion:RestClient.CommitsHandler) {
        let resource = DeviceInfo.commitsResource
        let url = self.links?.url(resource)
        if  let url = url, client = self.client
        {
            client.commits(url, commitsAfter: commitsAfter, limit: limit, offset: offset, completion: completion)
        }
        else
        {
            completion(result: nil, error: NSError.clientUrlError(domain:DeviceInfo.self, code:0, client: client, url: url, resource: resource))
        }
    }
    
    @objc public func user(completion:RestClient.UserHandler) {
        let resource = DeviceInfo.userResource
        let url = self.links?.url(resource)
        if  let url = url, client = self.client
        {
            client.user(url, completion: completion)
        }
        else
        {
            completion(user: nil, error: NSError.clientUrlError(domain:DeviceInfo.self, code:0, client: client, url: url, resource: resource))
        }
    }
    
    internal func updateNotificationTokenIfNeeded() {
        let newNotificationToken = FitpayNotificationsManager.sharedInstance.notificationsToken
        if newNotificationToken != "" {
            if newNotificationToken != self.notificationToken {
                update(nil, softwareRevision: nil, notifcationToken: newNotificationToken, completion: {
                    [weak self] (device, error) in
                    if error == nil && device != nil {
                        self?.notificationToken = device?.notificationToken
                    }
                })
            }
        }
    }
}

public class CardRelationship : NSObject, ClientModel, Mappable, SecretApplyable
{
    internal var links:[ResourceLink]?
    public var creditCardId:String?
    public var pan:String?
    public var expMonth:Int?
    public var expYear:Int?
    
    internal var encryptedData:String?
    private static let selfResource = "self"
    internal weak var client:RestClient?
    
    public required init?(_ map: Map)
    {
        
    }
    
    public func mapping(map: Map)
    {
        links <- (map["_links"], ResourceLinkTransformType())
        creditCardId <- map["creditCardId"]
        encryptedData <- map["encryptedData"]
        pan <- map["pan"]
        expMonth <- map["expMonth"]
        expYear <- map["expYear"]
    }
    
    internal func applySecret(secret:NSData, expectedKeyId:String?)
    {
        if let decryptedObj : CardRelationship? = JWEObject.decrypt(self.encryptedData, expectedKeyId: expectedKeyId, secret: secret) {
            self.pan = decryptedObj?.pan
            self.expMonth = decryptedObj?.expMonth
            self.expYear = decryptedObj?.expYear
        }
    }
    
    /**
     Get a single relationship
     
     - parameter completion:   RelationshipHandler closure
     */
    @objc public func relationship(completion:RestClient.RelationshipHandler) {
        let resource = CardRelationship.selfResource
        let url = self.links?.url(resource)
        if let url = url, client = self.client
        {
            client.relationship(url, completion: completion)
        }
        else
        {
            completion(relationship: nil, error: NSError.clientUrlError(domain:CardRelationship.self, code:0, client: client, url: url, resource: resource))
        }
    }
}

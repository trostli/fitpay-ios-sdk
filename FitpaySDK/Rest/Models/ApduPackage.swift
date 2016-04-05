import ObjectMapper

public enum APDUPackageResponseState : String {
    case SUCCESSFUL = "SUCCESSFUL"
    case FAILED = "FAILED"
    case EXPIRED = "EXPIRED"
}

public class ApduPackage : Mappable
{
    public var links:[ResourceLink]?
    public var seIdType:String?
    public var targetDeviceType:String?
    public var targetDeviceId:String?
    public var packageId:String?
    public var seId:String?
    public var targetAid:String?
    public var apduCommands:[APDUCommand]?
    
    public var state:APDUPackageResponseState?
    public var executedEpoch:CLong?
    public var executedDuration:Int?
    
    public var validUntil:String?
    public var validUntilEpoch:CLong?
    public var apduPackageUrl:String?
    
    public static let successfullResponse = NSData(bytes: [0x90, 0x00] as [UInt8], length: 2)
    
    init() {
    }
    
    public required init?(_ map: Map)
    {
    }
    
    public func mapping(map: Map)
    {
        links <- (map["_links"], ResourceLinkTransformType())
        seIdType <- map["seIdType"]
        targetDeviceType <- map["targetDeviceType"]
        targetDeviceId <- map["targetDeviceId"]
        packageId <- map["packageId"]
        seId <- map["seId"]
        apduCommands <- map["commandApdus"]
        validUntil <- map["validUntil"]
        validUntilEpoch <- map["validUntilEpoch"]
        apduPackageUrl <- map["apduPackageUrl"]
    }
    
    public var responseDictionary : [String:AnyObject] {
        get {
            var dic : [String:AnyObject] = [:]
            
            if let packageId = self.packageId {
                dic["packageId"] = packageId
            }
            
            if let state = self.state {
                dic["state"] = state.rawValue
            }
            
            if let executed = self.executedEpoch {
                dic["executedEpoch"] = executed
            }
            
            if state == APDUPackageResponseState.EXPIRED {
                return dic
            }
            
            if let executedDuration = self.executedDuration {
                dic["executedDuration"] = executedDuration
            }
            
            if let apduResponses = self.apduCommands {
                if apduResponses.count > 0 {
                    var responsesArray : [AnyObject] = []
                    for resp in apduResponses {
                        responsesArray.append(resp.responseDictionary)
                    }
                    
                    dic["apduResponses"] = responsesArray
                }
            }
            
            return dic
        }
    }
    
}

public class APDUCommand : Mappable {
    public var links:[ResourceLink]?
    public var commandId:String?
    public var groupId:Int = 0
    public var sequence:Int = 0
    public var command:String?
    public var type:String?
    
    public var responseCode:String?
    public var responseData:String?
    
    init() {
    }
    
    public required init?(_ map: Map)
    {
        
    }
    
    public func mapping(map: Map)
    {
        links <- (map["_links"], ResourceLinkTransformType())
        commandId <- map["commandId"]
        groupId <- map["groupId"]
        sequence <- map["sequence"]
        command <- map["command"]
        type <- map["type"]
    }
    
    public var responseDictionary : [String:AnyObject] {
        get {
            var dic : [String:AnyObject] = [:]
            
            if let commandId = self.commandId {
                dic["commandId"] = commandId
            }
            
            if let responseCode = self.responseCode {
                dic["responseCode"] = responseCode
            }
            
            if let responseData = self.responseData {
                dic["responseData"] = responseData
            }
            
            return dic
        }
    }
}

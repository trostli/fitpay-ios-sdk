import ObjectMapper

public enum APDUPackageResponseState : String {
    case PROCESSED = "PROCESSED"
    case FAILED = "FAILED"
    case ERROR = "ERROR"
    case EXPIRED = "EXPIRED"
}

public class ApduPackage : Mappable
{
    internal var links:[ResourceLink]?
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
    
    public var isExpired : Bool {
        return validUntilEpoch <= CLong(NSDate().timeIntervalSince1970)
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
                        if let _ = resp.responseData {
                            responsesArray.append(resp.responseDictionary)
                        }
                    }
                    
                    dic["apduResponses"] = responsesArray
                }
            }
            
            return dic
        }
    }
    
}

public enum APDUResponseType : Int {
    case Success = 0x0
    case Warning
    case Error
}

public class APDUCommand : Mappable {
    internal var links:[ResourceLink]?
    public var commandId:String?
    public var groupId:Int = 0
    public var sequence:Int = 0
    public var command:String?
    public var type:String?
    
    public var responseCode:String?
    public var responseData:String?
    
    public var responseType : APDUResponseType? {
        guard let responseCode = self.responseCode, responseData = responseCode.hexToData() else {
            return nil
        }
        
        for successCode in APDUCommand.successResponses {
            if UInt8(responseData.bytes[0]) != successCode[0] {
                continue
            }
            
            if successCode.count == 1 {
                return APDUResponseType.Success
            }
            
            if responseData.length > 1 && successCode.count > 1 {
                if UInt8(responseData.bytes[1]) == successCode[1] {
                    return APDUResponseType.Success
                }
            }
        }
        
        for warningCode in APDUCommand.warningResponses {
            if UInt8(responseData.bytes[0]) != warningCode[0] {
                continue
            }
            
            if warningCode.count == 1 {
                return APDUResponseType.Warning
            }
            
            if responseData.length > 1 && warningCode.count > 1 {
                if UInt8(responseData.bytes[1]) == warningCode[1] {
                    return APDUResponseType.Warning
                }
            }
        }
        
        return APDUResponseType.Error
    }
    
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
    
    
    internal static let successResponses : [[UInt8]] = [
        [90, 00],
        [61/*, XX */]
    ]
    
    internal static let warningResponses : [[UInt8]] = [
        [62/*, XX */],
        [63/*, XX */]
    ]
}

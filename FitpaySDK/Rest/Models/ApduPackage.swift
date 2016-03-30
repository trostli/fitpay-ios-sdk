
public class ApduPackage
{
    public var packageId:String?
    public var state:String? //TODO: consider adding enum
    public var executed:String?
    public var executedDuration:Int?
    public var apduResponses:[ApduResponse]?
    
    public var commands : [NSData]?
    
    public var dictoinary : [String:AnyObject] {
        get {
            var dic : [String:AnyObject] = [:]
            
            if let packageId = self.packageId {
                dic["packageId"] = packageId
            }
            
            if let state = self.state {
                dic["state"] = state
            }
            
            if let executed = self.executed {
                dic["executedTs"] = executed
            }
            
            if let executedDuration = self.executedDuration {
                dic["executedDuration"] = executedDuration
            }
            
            if let apduResponses = self.apduResponses {
                if apduResponses.count > 0 {
                    var responsesArray : [AnyObject] = []
                    for resp in apduResponses {
                        responsesArray.append(resp.dictoinary)
                    }
                    
                    dic["apduResponses"] = responsesArray
                }
            }
            
            return dic
        }
    }
    
}

public class ApduResponse
{
    public var commandId:String?
    public var responseCode:String?
    public var responseData:String?
    
    public var dictoinary : [String:AnyObject] {
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

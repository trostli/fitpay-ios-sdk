
public class ApduPackage
{
    public var packageId:String?
    public var state:String? //TODO: consider adding enum
    public var executed:String?
    public var executedDuration:Int?
    public var apduResponses:[ApduResponse]?
}

public class ApduResponse
{
    public var commandId:String?
    public var responseCode:String?
    public var responseData:String?
}

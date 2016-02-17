
class ApduPackage
{
    var packageId:String?
    var state:String? //TODO: consider adding enum
    var executed:String?
    var executedDuration:Int?
    var apduResponses:[ApduResponse]?
}

class ApduResponse
{
    var commandId:String?
    var responseCode:String?
    var responseData:String?
}

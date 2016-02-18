
class VerificationMethod
{
    var links:[ResourceLink]?
    var verificationId:String?
    var state:String? //TODO: consider creating enum
    var methodType:String? //TODO: consider creating enum
    var value:String?
    var verificationResult:String? //TODO: consider creating enum
    var created:String?
    var createdEpoch:Int?
    var lastModified:String?
    var lastModifiedEpoch:Int?
    var verified:String?
    var verifiedEpoch:String?
}

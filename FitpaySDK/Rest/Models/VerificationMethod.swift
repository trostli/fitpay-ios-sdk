
public class VerificationMethod
{
    public var links:[ResourceLink]?
    public var verificationId:String?
    public var state:String? //TODO: consider creating enum
    public var methodType:String? //TODO: consider creating enum
    public var value:String?
    public var verificationResult:String? //TODO: consider creating enum
    public var created:String?
    public var createdEpoch:CLong?
    public var lastModified:String?
    public var lastModifiedEpoch:CLong?
    public var verified:String?
    public var verifiedEpoch:String?
}


public class Commit
{
    var links:[ResourceLink]?
    var commitType:CommitType?
    var payload:Payload?
    var created:Int?
    var previousCommit:String?
    var commit:String?
}

public enum CommitType : String
{
    case CREDITCARD_CREATED = "CREDITCARD_CREATED"
    case CREDITCARD_DEACTIVATED = "CREDITCARD_DEACTIVATED"
    case CREDITCARD_ACTIVATED = "CREDITCARD_ACTIVATED"
    case CREDITCARD_DELETED = "CREDITCARD_DELETED"
    case RESET_DEFAULT_CREDITCARD = "RESET_DEFAULT_CREDITCARD"
    case SET_DEFAULT_CREDITCARD = "SET_DEFAULT_CREDITCARD"
}

public class Payload
{
    var createdEpoch:Int?
    var reason:String?
    var cvv:String?
    var address:Address?
    var externalTokenReference:String?
    var deviceRelationships:[DeviceRelationships]?
    var cardType:String?
    var causedBy:CreditCardInitiator?
    var lastModifiedEpoch:Int?
    var userId:String?
    var created:String?
    var lastModified:String?
    var expMonth:Int?
    var targetDeviceType:String?
    var expYear:Int?
    var targetDeviceId:String?
    var name:String?
    var state:String? //TODO: consider adding enum
    var pan:String?
    var cardMetaData:CardMetadata?
}
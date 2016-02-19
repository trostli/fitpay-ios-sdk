
public class Commit
{
    var links:[ResourceLink]?
    var commitType:CommitType?
    var payload:Payload?
    var created:Int64?
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
    case APDU_PACKAGE = "APDU_PACKAGE"
}

public class Payload
{
    var info = [String : AnyObject]()
}
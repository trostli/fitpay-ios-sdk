
import ObjectMapper

public class Commit : Mappable
{
    var links:[ResourceLink]?
    var commitType:CommitType?
    var payload:Payload?
    var created:CLong?
    var previousCommit:String?
    var commit:String?
    
    public required init?(_ map: Map)
    {
        
    }
    
    public func mapping(map: Map)
    {
        
    }
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
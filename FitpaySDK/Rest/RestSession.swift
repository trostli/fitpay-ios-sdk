
import Foundation

public enum AuthScope : String
{
    case userRead =  "user.read"
    case userWrite = "user.write"
    case tokenRead = "token.read"
    case tokenWrite = "token.write"
}


public class RestSession
{
    typealias LoginHandler = (ErrorType?)->Void

    func login(password:String, completion:LoginHandler)
    {

    }
}

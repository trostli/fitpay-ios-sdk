
import Foundation
import Alamofire

public enum AuthScope : String
{
    case userRead =  "user.read"
    case userWrite = "user.write"
    case tokenRead = "token.read"
    case tokenWrite = "token.write"
}


 public class RestSession
{
    public static let sharedSession = RestSession()

    public typealias LoginHandler = (ErrorType?)->Void
    public func login(password:String, completion:LoginHandler)
    {

    }

    internal typealias AcquireAccessTokenHandler = (String?, ErrorType?)->Void
    internal func acquireAccessToken(clientId clientId:String, clientSecret:String, completion:AcquireAccessTokenHandler)
    {
        let pair = "\(clientId):\(clientSecret)"
        let bytes = pair.dataUsingEncoding(NSUTF8StringEncoding)!
        let credentials = bytes.base64EncodedStringWithOptions(NSDataBase64EncodingOptions(rawValue:0))
        let headers = ["Authorization" : "Bearer \(credentials)"]
        let manager = Manager.sharedInstance
        let parameters = ["grant_type" : "client_credentials"]
        let request = manager.request(.POST, AUTH_URL, parameters: parameters, encoding: .URLEncodedInURL, headers: headers)



    }
}

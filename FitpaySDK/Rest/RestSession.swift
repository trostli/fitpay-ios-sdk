
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

    private var clientId:String?
    private var redirectUri:String?

    public func configure(clientId:String, redirectUri:String)
    {
        self.clientId = clientId
        self.redirectUri = redirectUri
    }

    public typealias LoginHandler = (ErrorType?)->Void
    public func login(password:String, completion:LoginHandler)
    {

    }

    internal typealias AcquireAccessTokenHandler = (String?, ErrorType?)->Void
    internal func acquireAccessToken(clientId clientId:String, redirectUri:String, username:String, password:String, completion:AcquireAccessTokenHandler)
    {
        let manager = Manager.sharedInstance



        let parameters = [
                "response_type" : "token",
                "client_id" : clientId,
                "redirect_uri" : redirectUri,
                "credentials" : ["username" : username, "password" : password ].JSONString!
        ]

        let request = manager.request(.POST, AUTH_URL, parameters: parameters, encoding: .URLEncodedInURL, headers: headers)



    }
}

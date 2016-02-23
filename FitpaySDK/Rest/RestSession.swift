
import Foundation
import AlamofireObjectMapper
import Alamofire
import ObjectMapper

public enum AuthScope : String
{
    case userRead =  "user.read"
    case userWrite = "user.write"
    case tokenRead = "token.read"
    case tokenWrite = "token.write"
}

internal class AuthorizationDetails : Mappable
{
    var tokenType:String?
    var accessToken:String?
    var expiresIn:String?
    var scope:String?
    var jti:String?

    required init?(_ map: Map)
    {
        
    }
    
    func mapping(map: Map)
    {
        tokenType <- map["token_type"]
        accessToken <- map["access_token"]
        expiresIn <- map["expires_in"]
        scope <- map["scope"]
        jti <- map["jti"]
    }
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

    public func login(login:String, password:String, completion:LoginHandler)
    {

    }

    internal typealias AcquireAccessTokenHandler = (AuthorizationDetails?, ErrorType?)->Void

    internal func acquireAccessToken(clientId clientId:String, redirectUri:String, username:String, password:String, completion:AcquireAccessTokenHandler)
    {
        let headers = ["Accept" : "application/json"]
        let parameters = [
                "response_type" : "token",
                "client_id" : clientId,
                "redirect_uri" : redirectUri,
                "credentials" : ["username" : username, "password" : password].JSONString!
        ]

        let request = Manager.sharedInstance.request(.POST, AUTHORIZE_URL, parameters: parameters, encoding:.URL, headers: headers)
    
        request.responseObject(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0))
        {
            (response: Response<AuthorizationDetails, NSError>) -> Void in

            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                completion(response.result.value, response.result.error)
            })
        }
    }
}

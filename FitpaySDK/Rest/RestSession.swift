
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
    private var credentials:String

    public init(consumerKey:String, consumerSecret:String)
    {
        let pair = "\(consumerKey):\(consumerSecret)"
        let bytes = pair.dataUsingEncoding(NSUTF8StringEncoding)!
        self.credentials = bytes.base64EncodedStringWithOptions(NSDataBase64EncodingOptions(rawValue:0))
    }

    public typealias AcquireAccessTokenHandler = (String?, ErrorType?)->Void

    public func acquireAccessToken(completion: AcquireAccessTokenHandler)
    {

    }

    public typealias  AuthorizeHandler = (ErrorType?)->Void

    public func authorize(scopes:[AuthScope], completion:AuthorizeHandler)
    {

    }
}

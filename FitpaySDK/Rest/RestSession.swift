
import Foundation

enum AuthScope : String
{
    case userRead =  "user.read"
    case userWrite = "user.write"
    case tokenRead = "token.read"
    case tokenWrite = "token.write"
}


class RestSession
{
    private var credentials:String

    init(consumerKey:String, consumerSecret:String)
    {
        let pair = "\(consumerKey):\(consumerSecret)"
        let bytes = pair.dataUsingEncoding(NSUTF8StringEncoding)!
        self.credentials = bytes.base64EncodedStringWithOptions(NSDataBase64EncodingOptions(rawValue:0))
    }

    typealias AcquireAccessTokenHandler = (String?, ErrorType?)->Void

    func acquireAccessToken(completion: AcquireAccessTokenHandler)
    {

    }

    typealias  AuthorizeHandler = (ErrorType?)->Void

    func authorize(scopes:[AuthScope], completion:AuthorizeHandler)
    {

    }
}

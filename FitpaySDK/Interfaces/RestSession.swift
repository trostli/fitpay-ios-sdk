
import Foundation

class RestSession
{
    private var consumerKey:String
    private var consumerSecret:String

    private lazy var credentials:String =
    {
        let pair = "\(self.consumerKey):\(self.consumerSecret)"
        let bytes = pair.dataUsingEncoding(NSUTF8StringEncoding)!
        return bytes.base64EncodedStringWithOptions(NSDataBase64EncodingOptions(rawValue:0))
    }()

    init(consumerKey:String, consumerSecret:String)
    {
        self.consumerKey = consumerKey
        self.consumerSecret = consumerSecret
    }

    func authorize()
    {
        // TODO: Continue here
    }



}

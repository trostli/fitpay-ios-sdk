
/// This data can be used to set or verify a user device relationship, retrieve commit changes for the device, etc...
public class WebViewSessionData
{
    public var userId:String
    public var deviceId:String
    public var token:String

    public init(userId:String, deviceId:String, token:String)
    {
        self.userId = userId
        self.deviceId = deviceId
        self.token = token
    }
}

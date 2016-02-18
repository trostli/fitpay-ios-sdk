
/// This data can then be used to set or verify a user device relationship, retrieve commit changes for the device, etc...
class WebViewSessionData
{
    var userId:String
    var deviceId:String
    var token:String

    init(userId:String, deviceId:String, token:String)
    {
        self.userId = userId
        self.deviceId = deviceId
        self.token = token
    }
}

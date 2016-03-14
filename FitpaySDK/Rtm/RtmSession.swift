
import Foundation
import Pusher
import ObjectMapper

public enum SyncErrorCode : Int
{
    case Unknown = 0
    case NoUserDataAvailable = 1
    case UnauthorizedTokenRejected = 2
    case CommitsCouldNotBeAppliedToDevice = 3
}

public class RtmSession : NSObject
{
    /**
     Completion handler

     - parameter NSURL?: Provides NSURL object to be used in WebView, or nil if error occurs
     - parameter ErrorType?: Provides error object, or nil if no error occurs
     */
    public typealias ConnectHandler = (NSURL?, ErrorType?)->Void

    /// Handles connection and provides URL for webview participant
    public var onConnect:ConnectHandler?

    /**
     Completion handler

     - parameter ErrorType?: Provides error object, or nil if no error occurs
     */
    public typealias ParticipantsReadyHandler = (ErrorType?)->Void

    /// Handles case when all participants have joined channel
    public var onParticipantsReady:ParticipantsReadyHandler?

    /**
     Completion handler

     - parameter WebViewSessionData?: Provides WebViewSessionData object
    */
    public typealias UserLoginHandler = (WebViewSessionData)->Void

    /// Handles User successful login and provides web view session details
    var onUserLogin:UserLoginHandler?

    private var authorizationURL:NSURL

    public init(authorizationURL:NSURL)
    {
        self.authorizationURL = authorizationURL
    }

     /**
      Establishes websocket connection, provides URL for webview member;
      When webview loads URL and establishes websocket connection RTM session is ready to be used by RTM client for exchanging messages;
      In order to be notified when particular event occurs, callback must be set (onConnect, onParticipantsReady, onUserLogin)
     
      - parameter deviceInfo: payment device object
     */
    public func connectAndWaitForParticipants(deviceInfo:DeviceInfo)
    {
        self.device = deviceInfo
        
        self.pusher = PTPusher(key: PUSHER_APPLICATION_API_KEY, delegate: self, encrypted: false)
        self.pusher?.connect()
    }

    /**
     Completion handler
    */
    public typealias SychronizationRequestHandler = ()->Void

    /// Handles notification when device synchronization is required
    public var onSychronizationRequest:SychronizationRequestHandler?

    /**
     Completion handler

     - parameter ErrorType?: Provides ErrorType object with SyncErrorCode, or nil if no error occurs
    */
    public typealias SychronizationCompleteHandler = (ErrorType?)->Void

    /// Handles device synchronization completion; if synchronization fails, error object with details is passed to completion closure
    public var onSychronizationComplete:SychronizationCompleteHandler?
    
    internal let expectedUsers : [String] = ["wv", "device"]
    internal var pusher : PTPusher? {
        willSet {
            if let pusher = self.pusher {
                pusher.delegate = nil
            }
        }
    }
    
    internal var channel : PTPusherPresenceChannel? {
        willSet {
            if let channel = self.channel {
                channel.removeAllBindings()
                channel.presenceDelegate = nil
            }
        }
    }
    
    internal var device : DeviceInfo?
    internal var keyPair : SECP256R1KeyPair = SECP256R1KeyPair()
    internal var wvPublicKey : String?
    internal var wvSessionData : WebViewSessionData?
    
    public enum ErrorCode : Int, ErrorType, RawIntValue
    {
        case UnknownError = 0
        case ConnectionProblem = 10001
    }
}

extension RtmSession : PTPusherDelegate {
    
    public func pusher(pusher: PTPusher!, connectionDidConnect connection: PTPusherConnection!) {
        if let device = self.device {
            guard connectToChannel(device) else {
                if let connectionCompletion = self.onConnect {
                    connectionCompletion(nil, NSError.error(code: ErrorCode.ConnectionProblem, domain: RtmSession.self, message: "Can't connect to the channel."))
                }
                return
            }
        }
    }
    
    internal func connectToChannel(device:DeviceInfo) -> Bool {
        guard let channelName = self.channelName(device) else {
            return false
        }
        
        pusher?.authorizationURL = self.authorizationURL
        self.channel = pusher?.subscribeToPresenceChannelNamed(channelName, delegate: self)
        
        return true
    }
    
    internal func channelName(device:DeviceInfo) -> String? {
        guard let deviceSecureElementId = device.secureElementId else {
            return nil
        }
        
        return deviceSecureElementId.SHA1
    }
}

extension RtmSession : PTPusherPresenceChannelDelegate {
    
    internal enum ChannelMessage : String {
        case ClientDeviceKey                = "client-device-key"
        case ClientWebViewKey               = "client-wv-key"
        case ClientDeviceKeyRequest         = "client-device-key-request"
        case ClientWebViewKeyRequest        = "client-wv-key-request"
        case ClientUserData                 = "client-user-data"
        case ClientUserDataAck              = "client-user-data-ack"
        case ClientUserDataFailed           = "client-user-data-failed"
        case ClientDeviceSync               = "client-device-sync"
        case ClientDeviceSyncAck            = "client-device-sync-ack"
        case ClientDeviceSyncDataRetrieved  = "client-device-sync-data-retrieved"
        case ClientDeviceSyncComplete       = "client-device-sync-complete"
    }
    
    public func presenceChannelDidSubscribe(channel: PTPusherPresenceChannel!) {
        if let connectionCompletion = self.onConnect {
            connectionCompletion(self.device != nil ? self.webViewUrl(self.device!) : nil, nil)
        }
        subscribeToEvents(channel)
        print(isChannelHasAllParticipants(channel))
    }
    
    public func presenceChannel(channel: PTPusherPresenceChannel!, memberAdded member: PTPusherChannelMember!) {
        print(isChannelHasAllParticipants(channel))
    }
    
    public func presenceChannel(channel: PTPusherPresenceChannel!, memberRemoved member: PTPusherChannelMember!) {
        print(isChannelHasAllParticipants(channel))
    }
    
    internal func webViewUrl(device:DeviceInfo) -> NSURL? {
        guard let jsonString = device.shortRTMRepersentation else {
            return nil
        }
        
        guard let base64String = jsonString.base64URLencoded() else {
            return nil
        }
        
        return NSURL(string: RTM_WEBVIEW_BASE_URL + "?deviceData=" + base64String)
    }
    
    internal func isChannelHasAllParticipants(channel: PTPusherPresenceChannel) -> Bool {
        var membersDictionary : [String:Bool] = [:]
        
        channel.members.enumerateObjectsUsingBlock {
            (obj, stop) -> Void in
            if let member = obj as? PTPusherChannelMember, let memberName = member.userInfo["user"] as? String {
                membersDictionary[memberName] = true
            }
        }
        
        for expectedMemberName in expectedUsers {
            if membersDictionary[expectedMemberName] != true {
                return false
            }
        }
        
        return true
    }
    
    internal func subscribeToEvents(channel: PTPusherPresenceChannel) {
        channel.bindToEventNamed(ChannelMessage.ClientWebViewKey.rawValue) {
            [unowned self] (event) -> Void in
            
            if let wvPublicKey = event.data["publicKey"] as? String {
                self.wvPublicKey = wvPublicKey
            }
        }
        
        channel.bindToEventNamed(ChannelMessage.ClientDeviceKeyRequest.rawValue) {
            [unowned self] (event) -> Void in
            if let publicKey = self.keyPair.publicKey {
                channel.triggerEventNamed(ChannelMessage.ClientWebViewKeyRequest.rawValue, data: "{\"requester\":\"device\"}")
                
                var requester = "wv"
                if let realRequester = event.data["requester"] as? String {
                    requester = realRequester
                }
                
                channel.triggerEventNamed(ChannelMessage.ClientDeviceKey.rawValue, data: "{\"publicKey\":\"\(publicKey)\",\"requester\":\"\(requester)\"}")
            }
        }
        
        channel.bindToEventNamed(ChannelMessage.ClientUserData.rawValue) {
            [unowned self] (event) -> Void in
            
            if let session = Mapper<WebViewSessionData>().map(event.data), let wvPublicKey = self.wvPublicKey {
                session.applySecret(self.keyPair.generateSecretForPublicKey(wvPublicKey)!, expectedKeyId: nil)
                self.wvSessionData = session
                
                if let onUserLogin = self.onUserLogin {
                    onUserLogin(self.wvSessionData!)
                }
                
                channel.triggerEventNamed(ChannelMessage.ClientUserDataAck.rawValue, data: "")
            } else {
                channel.triggerEventNamed(ChannelMessage.ClientUserDataFailed.rawValue, data: "{\"error\":\(ErrorCode.UnknownError.rawValue)}")
            }
        }
        
        channel.bindToEventNamed(ChannelMessage.ClientDeviceSync.rawValue) {
            [unowned self] (event) -> Void in
            if let onSychronizationRequest = self.onSychronizationRequest {
                onSychronizationRequest()
            }
            
            channel.triggerEventNamed(ChannelMessage.ClientDeviceSyncAck.rawValue, data: "")
            //TODO: retrieve the new commit
            channel.triggerEventNamed(ChannelMessage.ClientDeviceSyncDataRetrieved.rawValue, data: "")
            //TODO: commit applied to the device
            channel.triggerEventNamed(ChannelMessage.ClientDeviceSyncComplete.rawValue, data: "")
            
            if let onSychronizationComplete = self.onSychronizationComplete {
                onSychronizationComplete(nil)
            }
        }
    }
}

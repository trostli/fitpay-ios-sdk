
import Foundation

public enum SyncErrorCode : Int
{
    case Unknown = 0
    case NoUserDataAvailable = 1
    case UnauthorizedTokenRejected = 2
    case CommitsCouldNotBeAppliedToDevice = 3
}

public class RtmSession
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
     
      - parameter secureElementId: secure element Id (provided by payment device)
     */
    public func connectAndWaitForParticipants(secureElementId:String)
    {

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
}
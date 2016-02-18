
import Foundation

class RtmSession
{
    /**
     Completion handler

     - parameter NSURL?: Provides NSURL object to be used in WebView, or nil if error occurs
     - parameter ErrorType?: Provides error object, or nil if no error occurs
     */
    typealias ConnectHandler = (NSURL?, ErrorType?)->Void

    /// Handles connection and provides URL for webview participant
    var onConnect:ConnectHandler?

    /**
     Completion handler

     - parameter ErrorType?: Provides error object, or nil if no error occurs
     */
    typealias ParticipantsReadyHandler = (ErrorType?)->Void

    /// Handles case when all participants have joined channel
    var onParticipantsReady:ParticipantsReadyHandler?

    /**
     Completion handler

     - parameter WebViewSessionData?: Provides WebViewSessionData object
    */
    typealias UserLoginHandler = (WebViewSessionData)->Void

    /// Handles User successful login and provides web view session details
    var onUserLogin:UserLoginHandler?

    private var authorizationURL:NSURL

    init(authorizationURL:NSURL)
    {
        self.authorizationURL = authorizationURL
    }

     /**
      Establishes websocket connection, provides URL for webview member; When webview loads URL and establishes websocket connection RTM session is ready to be used by RTM client for exchanging messages
     
     - parameter secureElementId:   secure element Id (provided by payment device)
     */
    func connectAndWaitForParticipants(secureElementId:String)
    {

    }
    
    
    
    


}

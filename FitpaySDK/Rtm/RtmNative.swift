
import Foundation
import WebKit
import ObjectMapper

internal enum SessionJS: String {
    case function           = "window.fpIos.sessionDataAck"
    case sessionDataSuccess = "{status: 0}"
    case sessionDataFailed  = "{status: 1}"
}

internal enum SyncJS: String {
    case function            = "window.fpIos.syncAck"
    case syncBeginSuccess    = "{status: 0}"
    case syncBeginFailed     = "{status: 1}"
    case getCommitsSuccess   = "{status: 2}"
    case getCommitsFailed    = "{status: 3}"
    case applyCommitsSuccess = "{status: 4}"
    case applyCommitsFailed  = "{status: 5}"
    case noValidSessionData  = "{status: 6}"
}

public class RtmNative : NSObject, WKScriptMessageHandler {
    let url = API_BASE_URL
//    let url = "http://192.168.128.170:8001"

    let paymentDevice: PaymentDevice?
    var user: User?
    let rtmConfig: RtmConfig?
    let restSession: RestSession?
    let restClient: RestClient?
    var webViewSessionData: WebViewSessionData?
    var webview: WKWebView?
    
    public init(clientId:String, redirectUri:String, paymentDevice:PaymentDevice) {
        self.paymentDevice = paymentDevice
        paymentDevice.connect()
        self.rtmConfig = RtmConfig(clientId: clientId, redirectUri: redirectUri, paymentDevice: paymentDevice.deviceInfo!)
        self.restSession = RestSession(clientId: clientId, redirectUri: redirectUri)
        self.restClient = RestClient(session: self.restSession!)
        self.paymentDevice!.deviceInfo?.client = self.restClient
        SyncManager.sharedInstance.paymentDevice = paymentDevice
    }
    
    public func setWebView(webview:WKWebView!) {
        self.webview = webview
    }
    
    /**
     This returns the configuration for a WKWebView that will enable the iOS rtm bridge in the web app
     */
    public func wvConfig() -> WKWebViewConfiguration {
        let config:WKWebViewConfiguration = WKWebViewConfiguration()
        config.userContentController.addScriptMessageHandler(self, name: "rtmBridge")
        
        return config
    }
    
    /**
     This returns the request object clients will require in order to open a WKWebView
     */
    public func wvRequest() -> NSURLRequest {
        let JSONString = Mapper().toJSONString(rtmConfig!)
        let utfString = JSONString!.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: true)
        let encodedConfig = utfString?.base64URLencoded()
        let configuredUrl = "\(url)?config=\(encodedConfig! as String)"
        
        print(configuredUrl)
        
        let requestUrl = NSURL(string: configuredUrl)
        let request = NSURLRequest(URL: requestUrl!)
        return request
    }
    
    /**
     This is the implementation of WKScriptMessageHandler, and handles any messages posted to the RTM bridge from the web app
     */
    public func userContentController(userContentController: WKUserContentController, didReceiveScriptMessage message: WKScriptMessage) {
        let sentData = message.body as! NSDictionary
        
        // check the action and route accordingly
        if sentData["action"] as! String == "sync" {
            print("received sync message from web-view")
            handleSync()
        } else if sentData["action"] as! String == "userData" {
            print("received user session data from web-view")
            
            do {
                print("extracting data")
                let jsonData = try NSJSONSerialization.dataWithJSONObject(sentData["data"]!, options: NSJSONWritingOptions.PrettyPrinted)
                let jsonString = NSString(data: jsonData, encoding: NSUTF8StringEncoding)! as String
                let webViewSessionData = Mapper<WebViewSessionData>().map(jsonString)
                handleSessionData(webViewSessionData!)
            } catch let error as NSError {
                print(error)
            }
        } else {
            print("received unknown message from web-view")
        }
    }
    
    private func handleSync() -> Void {
        self.callWebView(SyncJS.function.rawValue, args: SyncJS.syncBeginSuccess.rawValue)

        SyncManager.sharedInstance.bindToSyncEvent(eventType: SyncEventType.SYNC_COMPLETED, completion: {
            (event) in
            print("rtm got sync completed event with id \(event.eventId) and data \(event.eventData)")
            self.callWebView(SyncJS.function.rawValue, args: SyncJS.applyCommitsSuccess.rawValue)
            SyncManager.sharedInstance.removeAllSyncBindings()
        })
        
        if (self.webViewSessionData != nil && self.user != nil ) {
            print("going to get commits")
            goSync()
        } else {
            print("no session data for sync")
            self.callWebView(SyncJS.function.rawValue, args: SyncJS.noValidSessionData.rawValue)
        }
    }
    
    private func handleSessionData(webViewSessionData:WebViewSessionData) -> Void {
        self.webViewSessionData = webViewSessionData
        self.restSession!.setWebViewAuthorization(webViewSessionData)

        restClient?.user(id: (self.webViewSessionData?.userId)!, completion: {
            (user, error) in
            
            guard (error == nil || user == nil) else {
                self.callWebView(SessionJS.function.rawValue, args: SessionJS.sessionDataFailed.rawValue)
                return
            }
            
            print("got user! \(user!.email)")
            self.user = user
            self.callWebView(SessionJS.function.rawValue, args: SessionJS.sessionDataSuccess.rawValue)
        })
    }
    
    private func callWebView(function:String, args:String) {
        self.webview!.evaluateJavaScript("\(function)(\(args));", completionHandler: {
            (result, error) in
            if error != nil {
                print(error)
            }
        })
    }
    
    func goSync() {
        if SyncManager.sharedInstance.sync(self.user!) != nil {
            self.callWebView(SyncJS.function.rawValue, args: SyncJS.getCommitsFailed.rawValue)
        }
    }
    
    func setTimeout(delay:NSTimeInterval, block:()->Void) -> NSTimer {
        return NSTimer.scheduledTimerWithTimeInterval(delay, target: NSBlockOperation(block: block), selector: #selector(NSOperation.main), userInfo: nil, repeats: false)
    }
}


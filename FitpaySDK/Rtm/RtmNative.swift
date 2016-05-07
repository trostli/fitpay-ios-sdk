
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
}

public class RtmNative : NSObject, WKScriptMessageHandler {
    let url = API_BASE_URL
//    let url = "http://192.168.128.170:8001"
    
    let paymentDevice: PaymentDevice?
    let rtmConfig: RtmConfig?
    let restSession: RestSession?
    var webViewSessionData: WebViewSessionData?
    var webview: WKWebView?
    
    public init(clientId:String, redirectUri:String, paymentDevice:PaymentDevice) {
        self.paymentDevice = paymentDevice
        paymentDevice.connect()
        self.rtmConfig = RtmConfig(clientId: clientId, redirectUri: redirectUri, paymentDevice: paymentDevice.deviceInfo!)
        self.restSession = RestSession(clientId: clientId, redirectUri: redirectUri)
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
        
//        let userId = webViewSessionData!.userId!
//        let deviceId = webViewSessionData?.deviceId!
//        let commitUrl = "\(url)/users/\(userId)/devices/\(deviceId)/commits"
        
//        now go sync somehow, but fake it for now
        _ = setTimeout(1.5, block: { () -> Void in
            self.callWebView(SyncJS.function.rawValue, args: SyncJS.applyCommitsSuccess.rawValue)
        })

    }
    
    private func handleSessionData(webViewSessionData:WebViewSessionData) -> Void {
        self.webViewSessionData = webViewSessionData
        self.restSession!.setAuthorization(webViewSessionData)
        self.callWebView(SessionJS.function.rawValue, args: SessionJS.sessionDataSuccess.rawValue)
    }
    
    private func callWebView(function:String, args:String) {
        print("calling: \(function)(\(args))")
        self.webview!.evaluateJavaScript("\(function)(\(args));", completionHandler: {
            (result, error) in
            if error != nil {
                print(error)
            } else {
                print("js call success")
                print(result)
            }
        })
    }
    
    func setTimeout(delay:NSTimeInterval, block:()->Void) -> NSTimer {
        return NSTimer.scheduledTimerWithTimeInterval(delay, target: NSBlockOperation(block: block), selector: #selector(NSOperation.main), userInfo: nil, repeats: false)
    }
}


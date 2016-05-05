
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
    // let url = API_BASE_URL
    let url = "http://localhost:8001"

    let rtmConfig: RtmConfig?
    let restSession: RestSession?
    let restClient: RestClient?
    var webViewSessionData: WebViewSessionData?
    var webview: WKWebView?
    
    public init(config:RtmConfig, webview:WKWebView?) {
        // set the config and webview
        self.rtmConfig = config
        self.webview = webview
        
        // initialize a RestSession and RestClient
        self.restSession = RestSession(clientId: rtmConfig!.clientId, redirectUri: rtmConfig!.redirectUri)
        self.restClient = RestClient(session: restSession!)
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
        let requestUrl = NSURL(string: url )
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
        
        let userId = webViewSessionData!.userId!
        let deviceId = webViewSessionData?.deviceId!
        let commitUrl = "\(url)/users/\(userId)/devices/\(deviceId)/commits"
        
        restClient?.commits(commitUrl, parameters: nil, completion: {
            (commits, error) -> Void in
            
            if error != nil {
                self.callWebView(SyncJS.function.rawValue, args: SyncJS.getCommitsFailed.rawValue)
            } else {
                self.callWebView(SyncJS.function.rawValue, args: SyncJS.getCommitsSuccess.rawValue)
                
                // now what should we do with the commits?
                for commit in commits!.results! {
                    print(commit.commitType)
                    // return apply success for now
                    self.callWebView(SyncJS.function.rawValue, args: SyncJS.applyCommitsSuccess.rawValue)
                }
            }
        })
        
    }
    
    private func handleSessionData(webViewSessionData:WebViewSessionData) -> Void {
        self.webViewSessionData = webViewSessionData
        self.restSession!.setAuthorization(webViewSessionData)
        self.callWebView(SessionJS.function.rawValue, args: SessionJS.sessionDataSuccess.rawValue)
    }
    
    private func callWebView(function:String, args:String) {
        self.webview!.evaluateJavaScript("\(function)(\(args))", completionHandler: nil)
    }
}


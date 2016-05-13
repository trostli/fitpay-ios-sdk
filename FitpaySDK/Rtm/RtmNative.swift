
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
    let url = BASE_URL
    let paymentDevice: PaymentDevice?
    var user: User?
    let rtmConfig: RtmConfig?
    let restSession: RestSession?
    let restClient: RestClient?
    var webViewSessionData: WebViewSessionData?
    var webview: WKWebView?

    var sessionDataCallBackId: Int?
    var syncCallBacks = [Int]()
    
    public init(clientId:String, redirectUri:String, paymentDevice:PaymentDevice) {
        self.paymentDevice = paymentDevice
        paymentDevice.connect()
        self.rtmConfig = RtmConfig(clientId: clientId, redirectUri: redirectUri, paymentDevice: paymentDevice.deviceInfo!)

        self.restSession = RestSession(clientId: clientId, redirectUri: redirectUri)
        self.restClient = RestClient(session: self.restSession!)
        self.paymentDevice!.deviceInfo?.client = self.restClient
        SyncManager.sharedInstance.paymentDevice = paymentDevice

        super.init()
        self.bindEvents()
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
     This is the implementation of WKScriptMessageHandler, and handles any messages posted to the RTM bridge from the web app. The 
     callBackId corresponds to a JS callback that will resolve a promise stored in window.RtmBridge that will be called with the 
     result of the action once completed. It expects a message with the following format:

        {
            "callBackId": 1,
            "data": {
                "action": "action",
                "data": {
                    "userId": "userId",
                    "deviceId": "userId",
                    "token": "token"
                }
            }
        }
     */
    public func userContentController(userContentController: WKUserContentController, didReceiveScriptMessage message: WKScriptMessage) {
        let sentData = message.body as! NSDictionary
        
        // check the action and route accordingly
        if sentData["data"]!["action"] as! String == "sync" {
            print("received sync message from web-view")
            handleSync(sentData["callBackId"] as! Int)
        } else if sentData["data"]!["action"] as! String == "userData" {
            print("received user session data from web-view")

            sessionDataCallBackId = sentData["callBackId"] as? Int

            do {
                let data = sentData["data"]!["data"]!
                let jsonData = try NSJSONSerialization.dataWithJSONObject(data!, options: NSJSONWritingOptions.PrettyPrinted)
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
    
    private func handleSync(callBackId:Int) -> Void {
        if (self.webViewSessionData != nil && self.user != nil ) {
            print("going to get commits")

            syncCallBacks.append(callBackId)

            if !SyncManager.sharedInstance.isSyncing {
                goSync()
            }
        } else {
            print("no session data for sync")
            self.callBack(syncCallBacks.first!, success: false, response: "{status: 3}")

        }
    }
    
    private func handleSessionData(webViewSessionData:WebViewSessionData) -> Void {
        self.webViewSessionData = webViewSessionData
        self.restSession!.setWebViewAuthorization(webViewSessionData)

        restClient?.user(id: (self.webViewSessionData?.userId)!, completion: {
            (user, error) in
            
            guard (error == nil || user == nil) else {
                self.callBack(self.sessionDataCallBackId!, success: false, response: "{status: 1, reason: \(error.debugDescription)}")
                return
            }
            
            print("got user! \(user!.email)")
            self.user = user
            self.callBack(self.sessionDataCallBackId!, success: true, response: "{status: 0}")
        })
    }

    private func rejectAndResetSyncCallbacks(error:String) {
        for cb in self.syncCallBacks {
            callBack(cb, success: false, response: error)
        }

        self.syncCallBacks = [Int]()
    }

    private func resolveSync() {
        if let id = self.syncCallBacks.first {
            if self.syncCallBacks.count > 1 {
                self.callBack(id, success: true, response: "{status: 2, count: \(self.syncCallBacks.count)}")
                goSync()
            } else {
                self.callBack(id, success: true, response: "{status: 0}")
            }

            self.syncCallBacks.removeFirst()
        } else {
            print("stuff got fucked")
        }
    }

    private func callBack(callBackId:Int, success:Bool, response:String) {
        self.webview!.evaluateJavaScript("window.RtmBridge.resolve(\(callBackId), \(success), \(response))", completionHandler: {
            (result, error) in

            if error != nil {
                print("error")
            }
        })
    }

    func goSync() {
        if SyncManager.sharedInstance.sync(self.user!) != nil {
            rejectAndResetSyncCallbacks("{status: 1, reason: \"syncManager failed to regulate sequentail syncs\"")
        }
    }

    func bindEvents() {
        SyncManager.sharedInstance.bindToSyncEvent(eventType: SyncEventType.SYNC_COMPLETED, completion: {
            (event) in

            print("rtm got sync completed event with id \(event.eventId) and data \(event.eventData)")
            self.resolveSync()
        })
    }

}



import UIKit
import WebKit
import FitpaySDK

class WebViewController: UIViewController {
    @IBOutlet var containerView : UIView! = nil
    var webView = WKWebView()
    var rtm: RtmNative?
    
    override func viewDidLoad() {
        print("loading web view")
        let rtmConfig = RtmConfig(clientId: "pagare", redirectUri: "http://example.com")
        rtm = RtmNative(config: rtmConfig)
        let config:WKWebViewConfiguration = rtm!.wvConfig()
        
        self.view.frame = self.view.bounds
        self.webView = WKWebView(frame: self.view.frame, configuration: config)
        
        self.view = self.webView
        self.webView.loadRequest((rtm!.wvRequest()))
        rtm?.setWebView(webView)
    }
}
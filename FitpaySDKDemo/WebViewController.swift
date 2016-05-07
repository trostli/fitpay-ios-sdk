
import UIKit
import WebKit
import FitpaySDK
import ObjectMapper

class WebViewController: UIViewController {
    @IBOutlet var containerView : UIView! = nil
    var webView = WKWebView()
    var rtm: RtmNative?
    
    override func viewDidLoad() {
        let device = PaymentDevice();
        device.changeDeviceInterface(MockPaymentDeviceInterface(paymentDevice: device))
        
        rtm = RtmNative(clientId: "pagare", redirectUri: "http://example.com", paymentDevice: device)
        let config:WKWebViewConfiguration = rtm!.wvConfig()
        
        self.view.frame = self.view.bounds
        self.webView = WKWebView(frame: self.view.frame, configuration: config)
        
        self.view = self.webView
        self.webView.loadRequest((rtm!.wvRequest()))
        rtm?.setWebView(webView)
    }
}
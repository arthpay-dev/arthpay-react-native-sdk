import Foundation
import WebKit
import React

@objc(ArthpaySdkViewManager)
class ArthpaySdkViewManager: RCTViewManager {
    
    override static func requiresMainQueueSetup() -> Bool {
        return true
    }
    
    override func view() -> UIView! {
        return CustomWebView()
    }
}

class CustomWebView: UIView, WKNavigationDelegate {
    private var webView: WKWebView!

    @objc var source: NSString = "" {
        didSet {
            loadWebView(urlString: source as String)
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupWebView()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupWebView()
    }

    private func setupWebView() {
        let config = WKWebViewConfiguration()
        webView = WKWebView(frame: self.bounds, configuration: config)
        webView.navigationDelegate = self
        webView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.addSubview(webView)
    }

    private func loadWebView(urlString: String) {
        guard let url = URL(string: urlString) else {
            print("Invalid URL: \(urlString)")
            return
        }
        DispatchQueue.main.async {
            let request = URLRequest(url: url)
            self.webView.load(request)
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        webView.frame = self.bounds
    }

    // MARK: - WKNavigationDelegate (Handle UPI / Deep Links)
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction,
                 decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {

        guard let url = navigationAction.request.url else {
            decisionHandler(.allow)
            return
        }

        let scheme = url.scheme?.lowercased() ?? ""
        let upiSchemes = ["upi", "phonepe", "gpay", "tez", "paytmmp", "intent"]

        if upiSchemes.contains(scheme) {
            // Try opening via system
            if UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            } else {
                print("No app installed to handle UPI URL: \(url.absoluteString)")
            }
            decisionHandler(.cancel)
            return
        }

        // Let normal HTTP/HTTPS requests proceed
        decisionHandler(.allow)
    }
}

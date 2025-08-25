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
func showToast(message: String, duration: Double = 2.0) {
    let toastLabel = UILabel()
    toastLabel.text = message
    toastLabel.textColor = .white
    toastLabel.backgroundColor = UIColor.black.withAlphaComponent(0.6)
    toastLabel.textAlignment = .center
    toastLabel.font = UIFont.systemFont(ofSize: 14)
    toastLabel.alpha = 0.0
    toastLabel.numberOfLines = 0

    let textSize = toastLabel.intrinsicContentSize
    let padding: CGFloat = 16
    let labelWidth = min(self.frame.width - 2 * padding, textSize.width + padding)
    let labelHeight = textSize.height + 20

    toastLabel.frame = CGRect(x: (self.frame.width - labelWidth) / 2,
                              y: self.frame.height - labelHeight - 40,
                              width: labelWidth,
                              height: labelHeight)
    toastLabel.layer.cornerRadius = 10
    toastLabel.clipsToBounds = true

    self.addSubview(toastLabel)

    UIView.animate(withDuration: 0.5, animations: {
        toastLabel.alpha = 1.0
    }) { _ in
        UIView.animate(withDuration: 0.5, delay: duration, options: .curveEaseOut, animations: {
            toastLabel.alpha = 0.0
        }) { _ in
            toastLabel.removeFromSuperview()
        }
    }
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
               DispatchQueue.main.async {
        self.showToast(message: "No app installed to handle UPI URL")
    }
            }
            decisionHandler(.cancel)
            return
        }

        // Let normal HTTP/HTTPS requests proceed
        decisionHandler(.allow)
    }
}

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

class CustomWebView: UIView, WKNavigationDelegate, WKUIDelegate {
    private var webView: WKWebView!

    @objc var source: NSString = "" {
        didSet {
            loadWebView(urlString: source as String)
        }
    }

    @objc var onResult: RCTDirectEventBlock?

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
        webView.uiDelegate = self
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

    private func showToast(message: String, duration: Double = 2.0) {
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

    // MARK: - WKNavigationDelegate
    func webView(_ webView: WKWebView,
                 decidePolicyFor navigationAction: WKNavigationAction,
                 decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {

        guard let url = navigationAction.request.url else {
            decisionHandler(.allow)
            return
        }

        let urlString = url.absoluteString.lowercased()

        // Handle /ordercallback?txnData=
        if urlString.contains("/ordercallback") && urlString.contains("txndata=") {
            if let txnData = extractTxnData(from: urlString) {
                parseTxnData(txnData)
            }
            decisionHandler(.allow)
            return
        }

        // UPI SCHEME HANDLING
        if url.scheme?.hasPrefix("upi") == true ||
            url.scheme?.hasPrefix("intent") == true ||
            url.scheme?.hasPrefix("tez") == true ||
            url.scheme?.hasPrefix("paytmmp") == true ||
            url.scheme?.hasPrefix("phonepe") == true {

            if UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            } else {
                DispatchQueue.main.async {
                    self.showToast(message: "No app installed to handle UPI payment.")
                    self.sendResultEvent(["status": "failed", "message": "No app installed"])
                }
            }
            decisionHandler(.cancel)
            return
        }

        decisionHandler(.allow)
    }

    private func extractTxnData(from url: String) -> String? {
        guard let range = url.range(of: "txndata=") else { return nil }
        let txnDataPart = url[range.upperBound...]
        let cleaned = txnDataPart.components(separatedBy: "&").first ?? ""
        return cleaned.removingPercentEncoding
    }

    private func parseTxnData(_ base64String: String) {
        guard let decodedData = Data(base64Encoded: base64String),
              let jsonStr = String(data: decodedData, encoding: .utf8),
              let jsonData = jsonStr.data(using: .utf8) else {
            self.showToast(message: "Payment Cancelled or Failed.")
            return
        }

        do {
            if let json = try JSONSerialization.jsonObject(with: jsonData) as? [String: Any] {
                let status = json["status"] as? String ?? ""
                let txnId = json["txnId"] as? String ?? ""
                let approvalRef = json["approvalRef"] as? String ?? ""
                let message = json["message"] as? String ?? ""

                if status == "02" && (!txnId.isEmpty || !approvalRef.isEmpty) {
                    showToast(message: "Payment Successful!")
                } else {
                    showToast(message: "Payment Failed or Cancelled.")
                }

                sendResultEvent(json)
            }
        } catch {
            print("Failed to parse txnData JSON: \(error)")
            showToast(message: "txnData parse error.")
        }
    }

    private func sendResultEvent(_ result: [String: Any]) {
        onResult?(result)
    }

    // MARK: - WKUIDelegate (for JavaScript confirm dialogs)
    func webView(_ webView: WKWebView,
                 runJavaScriptConfirmPanelWithMessage message: String,
                 initiatedByFrame frame: WKFrameInfo,
                 completionHandler: @escaping (Bool) -> Void) {

        if message.lowercased().contains("cancel") {
            let alert = UIAlertController(title: nil,
                                          message: "Are you sure you want to cancel?",
                                          preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in
                completionHandler(true)
            }))
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { _ in
                completionHandler(false)
            }))

            DispatchQueue.main.async {
                self.getTopViewController()?.present(alert, animated: true, completion: nil)
            }
        } else {
            // Auto-confirm for other messages
            completionHandler(true)
        }
    }

    private func getTopViewController() -> UIViewController? {
        var top = UIApplication.shared.connectedScenes
            .filter { $0.activationState == .foregroundActive }
            .compactMap { $0 as? UIWindowScene }
            .first?.windows
            .filter { $0.isKeyWindow }
            .first?.rootViewController

        while let presented = top?.presentedViewController {
            top = presented
        }
        return top
    }
}

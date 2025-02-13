package com.arthpaysdk

import android.webkit.WebView
import android.webkit.WebViewClient
import android.webkit.WebChromeClient
import android.os.Build
import android.webkit.CookieManager
import com.facebook.react.uimanager.SimpleViewManager
import com.facebook.react.uimanager.ThemedReactContext
import com.facebook.react.uimanager.annotations.ReactProp

class ArthpaySdkViewManager : SimpleViewManager<WebView>() {

    override fun getName() = "ArthpaySdkView"

    // Create the WebView instance
    override fun createViewInstance(reactContext: ThemedReactContext): WebView {
        val webView = WebView(reactContext)

        // Set WebView settings
        val webSettings = webView.settings
        webSettings.javaScriptEnabled = true // Enable JavaScript
        webSettings.domStorageEnabled = true // Enable DOM storage (localStorage)

        // Handle mixed content for HTTPS and HTTP
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
            webSettings.mixedContentMode = android.webkit.WebSettings.MIXED_CONTENT_ALWAYS_ALLOW
        }

        // Handle cookies
        CookieManager.getInstance().setAcceptThirdPartyCookies(webView, true)

        // Set WebViewClient to ensure links open inside the WebView
        webView.webViewClient = WebViewClient()

        // Optionally set a WebChromeClient for handling JavaScript alerts, etc.
        webView.webChromeClient = WebChromeClient()

        return webView
    }

    // ReactProp to accept a URL and load it into the WebView
    @ReactProp(name = "source")
    fun setSource(webView: WebView, source: String?) {
        println("HLLOOOOO")
        println(source)
        source?.let {
            webView.loadUrl(it) // Load the provided URL
        }
    }
}

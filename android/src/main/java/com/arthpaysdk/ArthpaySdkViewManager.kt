package com.arthpaysdk

import android.app.AlertDialog
import android.content.Intent
import android.content.pm.PackageManager
import android.net.Uri
import android.os.Build
import android.util.Base64
import android.webkit.*
import android.widget.Toast
import com.facebook.react.uimanager.SimpleViewManager
import com.facebook.react.uimanager.ThemedReactContext
import com.facebook.react.uimanager.annotations.ReactProp
import org.json.JSONObject
import java.net.URLDecoder

class ArthpaySdkViewManager : SimpleViewManager<WebView>() {

    override fun getName() = "ArthpaySdkView"

    override fun createViewInstance(reactContext: ThemedReactContext): WebView {
        val webView = WebView(reactContext)

        val webSettings = webView.settings
        webSettings.javaScriptEnabled = true
        webSettings.domStorageEnabled = true

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
            webSettings.mixedContentMode = WebSettings.MIXED_CONTENT_ALWAYS_ALLOW
            CookieManager.getInstance().setAcceptThirdPartyCookies(webView, true)
        }

        webView.webChromeClient = object : WebChromeClient() {
            override fun onJsConfirm(view: WebView?, url: String?, message: String?, result: JsResult?): Boolean {
                val context = view?.context
                if (context != null && result != null) {
                    AlertDialog.Builder(context)
                        .setMessage(message)
                        .setCancelable(false)
                        .setPositiveButton("OK") { _, _ -> result.confirm() }
                        .setNegativeButton("Cancel") { _, _ -> result.cancel() }
                        .setOnCancelListener { result.cancel() }
                        .show()
                    return true
                }
                return super.onJsConfirm(view, url, message, result)
            }
        }

        webView.webViewClient = object : WebViewClient() {

            override fun shouldOverrideUrlLoading(view: WebView, request: WebResourceRequest): Boolean {
                val url = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
                    request.url.toString()
                } else {
                    request.toString()
                }
                return handleUrl(url, reactContext)
            }

            @Deprecated("Deprecated in Java")
            override fun shouldOverrideUrlLoading(view: WebView, url: String): Boolean {
                return handleUrl(url, reactContext)
            }

            private fun handleUrl(url: String, reactContext: ThemedReactContext): Boolean {
                if (url.contains("/ordercallback") && url.contains("txnData=")) {
                    try {
                        val txnDataEncoded = url.substringAfter("txnData=").substringBefore("&")
                        val cleanedTxnData = URLDecoder.decode(txnDataEncoded, "UTF-8")
                        val decoded = String(Base64.decode(cleanedTxnData, Base64.DEFAULT))
                        val json = JSONObject(decoded)
                        val status = json.optString("status")

                        when (status) {
                            "02" -> Toast.makeText(reactContext, "Payment Successful!", Toast.LENGTH_SHORT).show()
                            "01", "00", "FAILED", "" -> Toast.makeText(reactContext, "Payment Cancelled or Failed.", Toast.LENGTH_SHORT).show()
                            else -> Toast.makeText(reactContext, "Unknown payment status: $status", Toast.LENGTH_SHORT).show()
                        }

                    } catch (e: Exception) {
                        e.printStackTrace()
                        Toast.makeText(reactContext, "Failed to decode payment response: ${e.localizedMessage}", Toast.LENGTH_LONG).show()
                    }
                    return false
                }

                if (
                    url.startsWith("upi://") ||
                    url.startsWith("tez://") ||
                    url.startsWith("intent://") ||
                    url.startsWith("phonepe://") ||
                    url.startsWith("paytmmp://")
                ) {
                    try {
                        var finalUrl = url

                        // Do NOT convert tez:// to upi:// here — keep original schemes for package-specific checks

                        val uri = Uri.parse(finalUrl)
                        val builder = uri.buildUpon().clearQuery()
                        uri.queryParameterNames.forEach { param ->
                            uri.getQueryParameter(param)?.let { value ->
                                builder.appendQueryParameter(param, value)
                            }
                        }
                        val cleanedUrl = builder.build().toString()
                        val cleanedUri = Uri.parse(cleanedUrl)
                        val pm = reactContext.packageManager

                        // PhonePe
                        if (url.startsWith("phonepe://")) {
                            val intent = Intent(Intent.ACTION_VIEW).apply {
                                data = cleanedUri
                                setPackage("com.phonepe.app")
                                addCategory(Intent.CATEGORY_BROWSABLE)
                                flags = Intent.FLAG_ACTIVITY_NEW_TASK
                            }
                            val resolveInfo = pm.resolveActivity(intent, PackageManager.MATCH_DEFAULT_ONLY)
                            if (resolveInfo != null) {
                                reactContext.startActivity(intent)
                            } else {
                                Toast.makeText(reactContext, "PhonePe not found on device.", Toast.LENGTH_SHORT).show()
                            }
                            return true
                        }

                        // Paytm
                        if (url.startsWith("paytmmp://")) {
                            val intent = Intent(Intent.ACTION_VIEW).apply {
                                data = cleanedUri
                                setPackage("net.one97.paytm")
                                addCategory(Intent.CATEGORY_BROWSABLE)
                                flags = Intent.FLAG_ACTIVITY_NEW_TASK
                            }
                            val resolveInfo = pm.resolveActivity(intent, PackageManager.MATCH_DEFAULT_ONLY)
                            if (resolveInfo != null) {
                                reactContext.startActivity(intent)
                            } else {
                                Toast.makeText(reactContext, "Paytm not found on device.", Toast.LENGTH_SHORT).show()
                            }
                            return true
                        }

                        // GPay - We only replace tez://upi/pay with upi://pay for GPay, then use setPackage

                        if (url.startsWith("tez://upi/pay") || url.startsWith("intent://")) {
                            // Fix tez:// scheme for GPay only here
                            val gpayUrl = when {
                                url.startsWith("tez://upi/pay") -> url.replaceFirst("tez://upi/pay", "upi://pay")
                                url.startsWith("intent://") -> url.replaceFirst("intent://", "upi://pay")
                                else -> url
                            }
                            val gpayUri = Uri.parse(gpayUrl)

                            val intent = Intent(Intent.ACTION_VIEW).apply {
                                data = gpayUri
                                setPackage("com.google.android.apps.nbu.paisa.user") // GPay package
                                addCategory(Intent.CATEGORY_BROWSABLE)
                                flags = Intent.FLAG_ACTIVITY_NEW_TASK
                            }

                            val resolveInfo = pm.resolveActivity(intent, PackageManager.MATCH_DEFAULT_ONLY)
                            if (resolveInfo != null) {
                                reactContext.startActivity(intent)
                            } else {
                                Toast.makeText(reactContext, "GPay app is not installed.", Toast.LENGTH_SHORT).show()
                            }
                            return true
                        }

                        // For other upi:// links without package, launch generic chooser
                        if (url.startsWith("upi://pay")) {
                            val intent = Intent(Intent.ACTION_VIEW).apply {
                                data = cleanedUri
                                addCategory(Intent.CATEGORY_BROWSABLE)
                                flags = Intent.FLAG_ACTIVITY_NEW_TASK
                            }
                            reactContext.startActivity(intent)
                            return true
                        }

                        Toast.makeText(reactContext, "No supported UPI app found.", Toast.LENGTH_SHORT).show()
                        return true

                    } catch (e: Exception) {
                        e.printStackTrace()
                        Toast.makeText(reactContext, "UPI link failed: ${e.localizedMessage}", Toast.LENGTH_LONG).show()
                        return true
                    }
                }

                return false
            }
        }

        return webView
    }

    @ReactProp(name = "source")
    fun setSource(webView: WebView, source: String?) {
        source?.let {
            webView.loadUrl(it)
        }
    }
}

package com.khizar1556.html_to_pdf_plus

import android.annotation.SuppressLint
import android.content.Context
import android.os.Build
import android.print.PrintAttributes
import android.webkit.WebView
import android.webkit.WebViewClient
import java.io.File
import android.print.PdfPrinter


class HtmlToPdfConverter {

    interface Callback {
        fun onSuccess(filePath: String)
        fun onFailure()
    }

    @SuppressLint("SetJavaScriptEnabled")
    fun convert(
        filePath: String,
        applicationContext: Context,
        printSize: String,
        orientation: String,
        marginTop: Double = 40.0,
        marginLeft: Double = 20.0,
        marginBottom: Double = 40.0,
        marginRight: Double = 20.0,
        callback: Callback
    ) {
        val webView = WebView(applicationContext)
        val htmlContent = File(filePath).readText(Charsets.UTF_8)
        webView.settings.javaScriptEnabled = true
        webView.settings.javaScriptCanOpenWindowsAutomatically = true
        webView.settings.allowFileAccess = true
        webView.loadDataWithBaseURL(null, htmlContent, "text/HTML", "UTF-8", null)

        webView.webViewClient = object : WebViewClient() {
            override fun onPageFinished(view: WebView, url: String) {
                super.onPageFinished(view, url)
                createPdfFromWebView(
                    webView,
                    applicationContext,
                    printSize,
                    orientation,
                    marginTop,
                    marginLeft,
                    marginBottom,
                    marginRight,
                    callback
                )
            }
        }
    }

    private fun createPdfFromWebView(
        webView: WebView,
        applicationContext: Context,
        printSize: String,
        orientation: String,
        marginTop: Double,
        marginLeft: Double,
        marginBottom: Double,
        marginRight: Double,
        callback: Callback
    ) {
        val path = applicationContext.filesDir
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.KITKAT) {
            var mediaSize = when (printSize) {
                "A0" -> PrintAttributes.MediaSize.ISO_A0
                "A1" -> PrintAttributes.MediaSize.ISO_A1
                "A2" -> PrintAttributes.MediaSize.ISO_A2
                "A3" -> PrintAttributes.MediaSize.ISO_A3
                "A4" -> PrintAttributes.MediaSize.ISO_A4
                "A5" -> PrintAttributes.MediaSize.ISO_A5
                "A6" -> PrintAttributes.MediaSize.ISO_A6
                "A7" -> PrintAttributes.MediaSize.ISO_A7
                "A8" -> PrintAttributes.MediaSize.ISO_A8
                "A9" -> PrintAttributes.MediaSize.ISO_A9
                "A10" -> PrintAttributes.MediaSize.ISO_A10
                else -> PrintAttributes.MediaSize.ISO_A4
            }

            mediaSize = when (orientation.uppercase()) {
                "LANDSCAPE" -> mediaSize.asLandscape()
                else -> mediaSize.asPortrait()
            }

            val attributes = PrintAttributes.Builder()
                .setMediaSize(mediaSize)
                .setResolution(PrintAttributes.Resolution("pdf", "pdf", 300, 300))
                .setMinMargins(
                    PrintAttributes.Margins.of(
                        marginLeft.toInt(),
                        marginTop.toInt(),
                        marginRight.toInt(),
                        marginBottom.toInt()
                    )
                )
                .build()

            val printer = PdfPrinter(attributes)

            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
                val adapter = webView.createPrintDocumentAdapter(temporaryDocumentName)
                printer.print(adapter, path, temporaryFileName, object : PdfPrinter.Callback {
                    override fun onSuccess(filePath: String) {
                        callback.onSuccess(filePath)
                        webView.destroy() // dispose webview
                    }

                    override fun onFailure() {
                        callback.onFailure()
                        webView.destroy() // dispose webview
                    }
                })
            }
        } else {
            callback.onFailure()
            webView.destroy()
        }
    }

    companion object {
        const val temporaryDocumentName = "TemporaryDocumentName"
        const val temporaryFileName = "TemporaryDocumentFile.pdf"
    }
}

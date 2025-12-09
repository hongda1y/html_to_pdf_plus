import Flutter
import UIKit
import WebKit

public class SwiftFlutterHtmlToPdfPlugin: NSObject, FlutterPlugin {
    var wkWebView: WKWebView!
    var urlObservation: NSKeyValueObservation?

    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "flutter_html_to_pdf", binaryMessenger: registrar.messenger())
        let instance = SwiftFlutterHtmlToPdfPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "convertHtmlToPdf":
            guard let args = call.arguments as? [String: Any],
                  let htmlFilePath = args["htmlFilePath"] as? String,
                  let width = args["width"] as? Int,
                  let height = args["height"] as? Int,
                  let linksClickable = args["linksClickable"] as? Bool else {
                result(FlutterError(code: "INVALID_ARGS", message: "Missing required arguments", details: nil))
                return
            }

            let topMargin = args["marginTop"] as? Double ?? 40
            let leftMargin = args["marginLeft"] as? Double ?? 20
            let bottomMargin = args["marginBottom"] as? Double ?? 40
            let rightMargin = args["marginRight"] as? Double ?? 20

            let viewController = UIApplication.shared.delegate?.window??.rootViewController
            wkWebView = WKWebView(frame: CGRect(origin: .zero, size: CGSize(width: width, height: height)))
            wkWebView.isHidden = true
            wkWebView.tag = 100
            viewController?.view.addSubview(wkWebView)

            // Disable text selection & touch callout
            let contentController = wkWebView.configuration.userContentController
            contentController.addUserScript(
                WKUserScript(
                    source: "document.documentElement.style.webkitUserSelect='none';",
                    injectionTime: .atDocumentEnd,
                    forMainFrameOnly: true
                )
            )
            contentController.addUserScript(
                WKUserScript(
                    source: "document.documentElement.style.webkitTouchCallout='none';",
                    injectionTime: .atDocumentEnd,
                    forMainFrameOnly: true
                )
            )
            wkWebView.scrollView.bounces = false

            let htmlFileContent = FileHelper.getContent(from: htmlFilePath)
            wkWebView.loadHTMLString(htmlFileContent, baseURL: Bundle.main.bundleURL)

            let printFormatter: UIPrintFormatter
            if linksClickable {
                printFormatter = UIMarkupTextPrintFormatter(markupText: htmlFileContent)
            } else {
                printFormatter = wkWebView.viewPrintFormatter()
            }

            urlObservation = wkWebView.observe(\.isLoading, changeHandler: { [weak self] webView, _ in
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                    guard let self = self else { return }

                    // Create PDF with custom margins
                    let margins = UIEdgeInsets(top: topMargin, left: leftMargin, bottom: bottomMargin, right: rightMargin)
                    let convertedFileURL = PDFCreator.create(
                        printFormatter: printFormatter,
                        width: Double(width),
                        height: Double(height),
                        margins: margins
                    )

                    let convertedFilePath = convertedFileURL.path

                    // Remove hidden webview
                    if let viewWithTag = viewController?.view.viewWithTag(100) {
                        viewWithTag.removeFromSuperview()

                        // Clear WKWebView cache
                        if #available(iOS 9.0, *) {
                            WKWebsiteDataStore.default().fetchDataRecords(ofTypes: WKWebsiteDataStore.allWebsiteDataTypes()) { records in
                                records.forEach { record in
                                    WKWebsiteDataStore.default().removeData(ofTypes: record.dataTypes, for: [record], completionHandler: {})
                                }
                            }
                        }
                    }

                    // Dispose WKWebView
                    self.urlObservation = nil
                    self.wkWebView = nil
                    result(convertedFilePath)
                }
            })

        default:
            result(FlutterMethodNotImplemented)
        }
    }
}

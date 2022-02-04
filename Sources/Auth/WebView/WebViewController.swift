//
//  File.swift
//  
//
//  Created by lu on 2022/2/3.
//

import Foundation
import UIKit
import WebKit

class WebViewController: UIViewController, WKScriptMessageHandler, WKUIDelegate, WKNavigationDelegate {
    var webView: WKWebView!
    var url: String!
    var completionHandler: ((_ tokens: [String: String])->Void)!

    override func loadView() {
        // create and config web view
        let webConfiguration = WKWebViewConfiguration()
        webConfiguration.preferences.javaScriptEnabled = true
        webConfiguration.preferences.javaScriptCanOpenWindowsAutomatically = true
        
        webView = WKWebView(frame: .zero, configuration: webConfiguration)
        webView.uiDelegate = self
        webView.navigationDelegate = self
        view = webView

        // remove cookies and local storage
        HTTPCookieStorage.shared.removeCookies(since: Date.distantPast)
        WKWebsiteDataStore.default().fetchDataRecords(ofTypes: WKWebsiteDataStore.allWebsiteDataTypes()) { records in
            records.forEach { record in
                WKWebsiteDataStore.default().removeData(ofTypes: record.dataTypes, for: [record], completionHandler: {})
                #if DEBUG
                print("WKWebsiteDataStore record deleted:", record)
                #endif
            }
        }
        WKWebsiteDataStore.default().removeData(ofTypes: [WKWebsiteDataTypeDiskCache, WKWebsiteDataTypeMemoryCache], modifiedSince: Date(timeIntervalSince1970: 0), completionHandler:{ })

        // 1. Enables native app features in the client application
        // 2. inject JS to capture console.log output and send to iOS
        var texts: [String] = []
        texts.append("window.enableNativeAppFeatures({type: 'IOS', biometricType: 'Touch', biometricIDEnabled: false, NFCSupported: false})")
        texts.append("function captureLog(msg) { window.webkit.messageHandlers.logHandler.postMessage(msg); } window.console.log = captureLog;")
        for text in texts {
            let source = text
            let script = WKUserScript(source: source, injectionTime: .atDocumentEnd, forMainFrameOnly: false)
            webView.configuration.userContentController.addUserScript(script)
        }

        // register the bridge script that listens for the output
        webView.configuration.userContentController.add(self, name: "setToken")
        webView.configuration.userContentController.add(self, name: "logHandler")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        let myURL = URL(string: url)
        let myRequest = URLRequest(url: myURL!)
        webView.load(myRequest)
    }

    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        if message.name == "logHandler" {
            print("console log: \(message.body)")
        } else if (message.name == "setToken") {
            let token = "\(message.body)"
            dismiss(animated: true, completion: nil)
            if let completion = completionHandler {
                completion(["token": token])
            }
        }
    }
}

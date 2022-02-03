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
        
        // inject JS to capture console.log output and send to iOS
        let source = "function captureLog(msg) { window.webkit.messageHandlers.logHandler.postMessage(msg); } window.console.log = captureLog;"
        let script = WKUserScript(source: source, injectionTime: .atDocumentEnd, forMainFrameOnly: false)
        webView.configuration.userContentController.addUserScript(script)
        
        // register the bridge script that listens for the output
        webView.configuration.userContentController.add(self, name: "logHandler")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        let myURL = URL(string: url)
        let myRequest = URLRequest(url: myURL!)
        webView.load(myRequest)
    }

    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        print("message name: " + message.name)
        if message.name == "logHandler" {
            let PREFIX = "__TOKEN: "
            let msg: String = "\(message.body)"
            //print("log message: \(msg)")
            if msg.starts(with: PREFIX) {
                let jwtToken: String = "\(msg.dropFirst(PREFIX.count))"
                //print("JWT: \(jwtToken)")
                dismiss(animated: true, completion: nil)
                if let completion = completionHandler {
                    completion(["jwt-token": jwtToken, "x-auth-token": "here"])
                }
            }
        }
    }
}

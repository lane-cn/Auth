//
//  ViewController.swift
//  Example
//
//  Created by lu on 2022/2/2.
//

import UIKit
import Auth

class ViewController: UIViewController {
    private let webViewButton = UIButton()
    private let basicButton = UIButton()
    private let messageLabel = UILabel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .systemBackground
        
        view.addSubview(webViewButton)
        webViewButton.setTitle("Web View Auth", for: .normal)
        webViewButton.frame = CGRect(x: 20, y: 120, width: 180, height: 40)
        webViewButton.backgroundColor = .gray
        webViewButton.setTitleColor(.black, for: .normal)
        webViewButton.addTarget(self, action: #selector(webViewAuthentication), for: .touchUpInside)
        
        view.addSubview(basicButton)
        basicButton.setTitle("Basic Auth", for: .normal)
        basicButton.frame = CGRect(x: 20, y: 170, width: 180, height: 40)
        basicButton.backgroundColor = .gray
        basicButton.setTitleColor(.black, for: .normal)
        basicButton.addTarget(self, action: #selector(basicAuthentication), for: .touchUpInside)

        view.addSubview(messageLabel)
        messageLabel.text = "No data"
        messageLabel.frame = CGRect(x: 20, y: 220, width: 300, height: 500)
        messageLabel.lineBreakMode = NSLineBreakMode.byWordWrapping
        messageLabel.numberOfLines = 0
    }
}

private extension ViewController {
    
    @objc func webViewAuthentication() {
        print("open web view login")
        let conf = Configuration()
        conf.loginUrl = "http://192.168.31.233:4200/auth/login"
        conf.fullscreen = true
        
        let auth = WebViewAuthentication(configuration: conf, completionHandler: {tokens in
            self.messageLabel.text = "\(tokens)"
        })
        auth.authenticate(parent: self)
    }
    
    @objc func basicAuthentication() {
        print("open native login")
        // TODO
    }
}


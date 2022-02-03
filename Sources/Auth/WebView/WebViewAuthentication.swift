//
//  File.swift
//  
//
//  Created by lu on 2022/2/3.
//

import Foundation
import UIKit
import WebKit

public class WebViewAuthentication: Authentication {
    var configuration: Configuration!
    var completionHandler: ((_ tokens: [String: String])->Void)!
    private var user: String!
    public var tokens: [String: String]!

    public var loginUser: String {
        user
    }
    
    public init(configuration: Configuration, completionHandler: @escaping ((_ tokens: [String: String]) -> Void)) {
        self.configuration = configuration
        self.completionHandler = completionHandler
    }

    public func authenticate(parent: UIViewController) {
        let controller = WebViewController()
        controller.url = configuration.loginUrl
        controller.completionHandler = completionHandler
        if configuration.fullscreen {
            controller.modalPresentationStyle = .fullScreen
        }
        parent.present(controller, animated: true) {
            print("present web view")
        }
    }
}

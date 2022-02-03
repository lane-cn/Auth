//
//  File.swift
//  
//
//  Created by lu on 2022/1/28.
//

import Foundation

protocol Authorization {
    
    init(_ loginUser: String, _ tokens: [String: String])
    
    func getRequest(url: String) -> URLRequest
}

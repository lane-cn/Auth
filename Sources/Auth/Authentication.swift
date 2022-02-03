//
//  File.swift
//  
//
//  Created by lu on 2022/1/28.
//

import Foundation
import UIKit

protocol Authentication {
    
    var loginUser: String {get}
    
    func authenticate(parent: UIViewController)
}

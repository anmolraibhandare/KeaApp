//
//  Alert.swift
//  Kea
//
//  Created by Anmol Raibhandare on 9/3/20.
//  Copyright © 2020 Anmol Raibhandare. All rights reserved.
//

import Foundation
import UIKit

class Alert {
    
    // MARK: Alert Function
    
    static func showAlert(style: UIAlertController.Style, title: String?, message: String?, actions: [UIAlertAction] = [UIAlertAction(title: "Ok", style: .cancel, handler: nil)], completion: (() -> Swift.Void)? = nil) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: style)
        for action in actions{
            alert.addAction(action)
            
        }
    }
}

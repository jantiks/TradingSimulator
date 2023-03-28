//
//  UIApplicationExtension.swift
//  TradingSimulator
//
//  Created by Tigran on 28.03.23.
//

import UIKit

extension UIApplication {
    func endEditing() {
        sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}


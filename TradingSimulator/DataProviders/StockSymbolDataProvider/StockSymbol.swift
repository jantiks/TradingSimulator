//
//  StockSymbol.swift
//  TradingSimulator
//
//  Created by Tigran on 24.03.23.
//

import Foundation

struct StockSymbol: Decodable {
    let name: String
    let exchange: String
}

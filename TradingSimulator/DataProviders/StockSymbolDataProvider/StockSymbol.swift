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

struct SimpleStockModel: Identifiable {
    var id: String
    let symbol: StockSymbol
    let price: Double
    let gains: Double
    let holdingGains: Double? = nil
    let holdingGainsPercent: Double? = nil
    let image: String
}

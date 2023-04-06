//
//  StockSymbol.swift
//  TradingSimulator
//
//  Created by Tigran on 24.03.23.
//

import Foundation

struct StockSymbol: Decodable {
    let ticker: String
    let name: String
    let marketCap: Double
    
    enum CodingKeys: CodingKey {
        case symbol
        case name
        case marketCap
    }
    
    init(ticker: String, name: String, marketCap: Double) {
        self.ticker = ticker
        self.name = name
        self.marketCap = marketCap
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.ticker = try container.decode(String.self, forKey: .symbol)
        self.name = try container.decode(String.self, forKey: .name)
        self.marketCap = Double(try container.decode(String.self, forKey: .marketCap)) ?? 0
    }
}

struct SimpleStockModel: Identifiable {
    var id: String = UUID().uuidString
    let symbol: StockSymbol
    let price: Double
    let gains: Double
    let holdingGains: Double? = nil
    let holdingGainsPercent: Double? = nil
    let image: String
}

//
//  StockSymbol.swift
//  TradingSimulator
//
//  Created by Tigran on 24.03.23.
//

import Foundation
import XCAStocksAPI

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

final class SimpleStockModel: Identifiable, ObservableObject {
    @Published var isUpdating = false
    
    var id: String = UUID().uuidString
    let symbol: StockSymbol
    @Published var price: Double
    @Published var gains: Double
    @Published var holdingGains: Double? = nil
    @Published var holdingGainsPercent: Double? = nil
    var image: String
    var lastUpdatedTime: Date? = nil
    
    init(isUpdating: Bool = false, id: String = UUID().uuidString, symbol: StockSymbol, price: Double, gains: Double, image: String) {
        self.isUpdating = isUpdating
        self.id = id
        self.symbol = symbol
        self.price = price
        self.gains = gains
        self.image = image
    }
    
    func updatePrice() async {
        guard lastUpdatedTime == nil || lastUpdatedTime!.timeIntervalSinceNow >= 5 * 60 else { return }
        lastUpdatedTime = Date()
        
        defer {
            isUpdating = false
        }
        
        isUpdating = true
        let stockApi = XCAStocksAPI()
        guard let stockQuote = try? await stockApi.fetchQuotes(symbols: symbol.ticker), let quote = stockQuote.first else { return }
        print("asd stockitem \(symbol.ticker) : \(quote.regularMarketPrice!)")
        price = quote.regularMarketPrice ?? 0.0
        gains = quote.regularMarketChangePercent ?? 0.0
    }
}

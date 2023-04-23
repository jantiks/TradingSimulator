//
//  StockSymbolDataProvider.swift
//  TradingSimulator
//
//  Created by Tigran on 24.03.23.
//

import Foundation

enum StockSymbolDataProviderErrors: Error {
    case fileNotFound, parseError
}

class StockSymbolDataProvider {
    
    static let shared = StockSymbolDataProvider()
    private var stockSymbols: [SimpleStockModel] = []
    
    private init() { }
    
    func getStockSymbols() throws -> [SimpleStockModel] {
        guard stockSymbols.isEmpty else {
            return stockSymbols
        }
        
        if let path = Bundle.main.path(forResource: "stocks", ofType: "json") {
            do {
                let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
                let symbols = try! JSONDecoder().decode([StockSymbol].self, from: data)
                stockSymbols = symbols.filter({ Double($0.ticker) == nil && Int($0.ticker) == nil }).map({ SimpleStockModel(symbol: $0, price: nil, gains: nil, image: "") })
                return stockSymbols
            } catch {
                throw StockSymbolDataProviderErrors.parseError
            }
        }
        
        throw StockSymbolDataProviderErrors.fileNotFound
    }
}

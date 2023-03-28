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

struct StockSymbolDataProvider {
    func getStockSymbols() throws -> [StockSymbol] {
        if let path = Bundle.main.path(forResource: "stocks", ofType: "json") {
            do {
                let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
                let symbols = try! JSONDecoder().decode([StockSymbol].self, from: data)
                    return symbols
            } catch {
                throw StockSymbolDataProviderErrors.parseError
            }
        }
        
        throw StockSymbolDataProviderErrors.fileNotFound
    }
}

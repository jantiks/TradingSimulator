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
        case ticker
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
        self.ticker = try container.decode(String.self, forKey: .ticker)
        self.name = try container.decode(String.self, forKey: .name)
        self.marketCap =  0
    }
}

final class SimpleStockModel: Identifiable, ObservableObject {
    @Published var isUpdating = false
    
    var id: String = UUID().uuidString
    let symbol: StockSymbol
    @Published var price: Double?
    @Published var gains: Double?
    @Published var holdingGains: Double? = nil
    @Published var holdingGainsPercent: Double? = nil
    @Published var chartData: ChartData?
    @Published var isUpdatingChartData = false
    var image: String
    var lastUpdatedTime: Date? = nil
    
    init(id: String = UUID().uuidString, symbol: StockSymbol, price: Double?, gains: Double?, image: String) {
        self.isUpdating = false
        self.id = id
        self.symbol = symbol
        self.price = price
        self.gains = gains
        self.image = image
    }
    
    func updateChartData() async {
        DispatchQueue.main.async {
            self.isUpdatingChartData = true
        }
        let stockApi = XCAStocksAPI()

        guard let chartData = try! await stockApi.fetchChartData(tickerSymbol: symbol.ticker, range: .oneYear) else {
            self.isUpdatingChartData = false
            return
        }
        print("asd task completed updateChartData \(chartData.indicators.count)")
        DispatchQueue.main.async {
            self.isUpdatingChartData = false
            self.chartData = chartData
        }
    }
    
    func updatePrice() async {
        guard lastUpdatedTime == nil || lastUpdatedTime!.timeIntervalSinceNow >= 5 * 60 else { return }
        lastUpdatedTime = Date()

        DispatchQueue.main.async {
            self.isUpdating = true
        }
        let stockApi = XCAStocksAPI()
        guard let stockQuote = try? await stockApi.fetchQuotes(symbols: symbol.ticker), let quote = stockQuote.first else {
            DispatchQueue.main.async {
                self.price = nil
                self.gains = nil
                self.isUpdating = false
            }
            return
        }

        DispatchQueue.main.async {
            self.price = quote.regularMarketPrice
            self.gains = quote.regularMarketChangePercent
            self.isUpdating = false
        }
    }
}

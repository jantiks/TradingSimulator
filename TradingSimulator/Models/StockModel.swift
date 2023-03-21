//
//  StockModel.swift
//  TradingSimulator
//
//  Created by Tigran on 19.03.23.
//

import Foundation


struct StockModel: Decodable {
    let price: Float?
    let currency: String?
    
    init(price: Float?, currency: String?) {
        self.price = price
        self.currency = currency
    }
    
    init(from pricingData: PricingData) {
        price = pricingData.price
        currency = pricingData.id
    }
}

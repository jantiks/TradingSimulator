//
//  StockItemView.swift
//  TradingSimulator
//
//  Created by Tigran on 28.03.23.
//

import SwiftUI

struct StockItemView: View {
    let stock: SimpleStockModel
    let showHoldingColumn: Bool = false
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(stock.symbol.ticker.uppercased())
                    .font(.headline)
                Text(stock.symbol.name)
                    
            }
            .padding(.leading, 15)
            .foregroundColor(Color.theme.accent)
            Spacer()
            if showHoldingColumn {
                VStack(alignment: .trailing) {
                    Text((stock.holdingGains ?? 0.0).asCurrencyWith6Decimals())
                        .bold()
                    Text((stock.holdingGainsPercent ?? 0.0).asPercentString())
                }
                .foregroundColor(Color.theme.accent)
            }
            
            VStack(alignment: .trailing) {
                Text(stock.price.asCurrencyWith6Decimals())
                    .bold()
                    .foregroundColor(Color.theme.accent)
                Text(stock.gains.asPercentString())
                    .foregroundColor(
                        stock.gains >= 0 ? Color.theme.green : Color.theme.red
                    )
            }
            .padding(.trailing, -10)
            .frame(width: UIScreen.main.bounds.width / 3.5)
        }
        .font(.subheadline)
    }
}

struct StockItemView_Previews: PreviewProvider {
    static var previews: some View {
        StockItemView(stock: SimpleStockModel(id: UUID().uuidString, symbol: StockSymbol(ticker: "BTC", name: "Bitcoin", marketCap: 100), price: 140, gains: 10, image: ""))
    }
}

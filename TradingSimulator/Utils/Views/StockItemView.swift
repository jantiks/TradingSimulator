//
//  StockItemView.swift
//  TradingSimulator
//
//  Created by Tigran on 28.03.23.
//

import SwiftUI

struct StockItemView: View {
    @StateObject var stock: SimpleStockModel
    let showHoldingColumn: Bool = false
    
    var body: some View {
        HStack(spacing: 0) {
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
                    Text((stock.holdingGains)?.asCurrencyWith6Decimals() ?? "--")
                        .bold()
                    Text((stock.holdingGainsPercent)?.asPercentString() ?? "--")
                }
                .foregroundColor(Color.theme.accent)
            }
            
            VStack(alignment: .trailing) {
                HStack {
                    Spacer()
                    if stock.isUpdating {
                        ProgressView()
                            .tint(Color.theme.accent)
                    } else {
                        VStack(alignment: .trailing) {
                            Text(stock.price?.asCurrencyWith6Decimals() ?? "--")
                                .bold()
                                .foregroundColor(Color.theme.accent)
                            Text(stock.gains?.asPercentString() ?? "--")
                                .foregroundColor(
                                    (stock.gains ?? 0.0) >= 0 ? Color.theme.green : Color.theme.red
                                )
                        }
                    }
                }
            }
            .padding(.trailing, 20)
            .frame(width: UIScreen.main.bounds.width / 3)
        }
        .task {
            await stock.updatePrice()
        }
        .font(.subheadline)
    }
}

struct StockItemView_Previews: PreviewProvider {
    static var previews: some View {
        StockItemView(stock: SimpleStockModel(id: UUID().uuidString, symbol: StockSymbol(ticker: "AACIW", name: "Bitcoin", marketCap: 100), price: 140, gains: 10, image: ""))
    }
}

//
//  TradeStockView.swift
//  TradingSimulator
//
//  Created by Tigran on 23.04.23.
//

import SwiftUI
import Charts
import XCAStocksAPI

extension Indicator: Identifiable {
    public var id: String {
        return UUID().uuidString
    }
}

struct TradeStockView: View {
    @StateObject var stock: SimpleStockModel
    
    var body: some View {
        NavigationView {
            VStack {
                Text(stock.symbol.ticker)
                    .font(.inputBold)
                Text(stock.symbol.name)
                    .foregroundColor(Color.theme.accent.opacity(0.6))
                Spacer()
                Chart {
                    ForEach(stock.chartData?.indicators ?? []) { stock in
                        RectangleMark(
                            x: .value("Date", stock.timestamp),
                            yStart: .value("Low", stock.low),
                            yEnd: .value("High", stock.high),
                            width: 3
                        )
                        .foregroundStyle(stock.low > stock.high ? .red : .green)
                    }
                }
                Spacer()
                VStack(alignment: .center) {
                    HStack {
                        Spacer()
                        Button {
                            print("Sell")
                        } label: {
                            VStack {
                                Text("SELL")
                                    .font(.inputBold)
                            }
                            .padding(.vertical, 2)
                            .padding(.horizontal, 40)
                            .padding()
                            .foregroundColor(.white)
                        }
                        .background(Color.red)
                        .cornerRadius(10)
                        Spacer()
                        Button {
                            print("Sell")
                        } label: {
                            VStack {
                                Text("BUY")
                                    .font(.inputBold)
                            }
                            .padding(.vertical, 2)
                            .padding(.horizontal, 40)
                            .padding()
                            .foregroundColor(.white)
                        }
                        .background(Color.blue)
                        .cornerRadius(10)
                        Spacer()
                    }
                }
            }
            .padding(.top, 10)
            
        }.task {
            await stock.updateChartData()
        }
    }
}

struct TradeStockView_Previews: PreviewProvider {
    static var previews: some View {
        TradeStockView(stock: .init(symbol: .init(ticker: "AAPL", name: "Apple inc", marketCap: 120), price: 120, gains: 10, image: ""))
    }
}

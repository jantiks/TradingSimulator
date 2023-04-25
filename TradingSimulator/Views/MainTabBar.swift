//
//  ContentView.swift
//  TradingSimulator
//
//  Created by Tigran on 19.03.23.
//

import SwiftUI
import XCAStocksAPI

extension MainTabBar {
    class ViewModel: ObservableObject {
        @Published var showTradingView = false
        init() {
            
        }
        
        func start() async {
            DispatchQueue.main.asyncAfter(deadline: .now() + 2, execute: {
                self.showTradingView = true
            })
        }
    }
}

struct MainTabBar: View {
    @StateObject var vm = ViewModel()
    var body: some View {
        TabView {
            MarketsView()
                .tabItem {
                    Label("Markets", systemImage: "chart.bar.fill")
                }
            TradingView()
                .tabItem {
                    Label("Trade", systemImage: "chart.line.uptrend.xyaxis")
                }
            PortfolioView()
                .tabItem {
                    Label("Portfolio", systemImage: "latch.2.case.fill")
                }
        }
        .fullScreenCover(isPresented: $vm.showTradingView, content: {
            TradeStockView(stock: .init(symbol: .init(ticker: "AAPL", name: "Apple inc.", marketCap: 120), price: 210, gains: 120, image: ""))
        })
        .task {
            await vm.start()
        }
    }
}

struct MainTabBar_Previews: PreviewProvider {
    static var previews: some View {
        MainTabBar()
    }
}

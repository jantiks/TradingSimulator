//
//  ContentView.swift
//  TradingSimulator
//
//  Created by Tigran on 19.03.23.
//

import SwiftUI
import XCAStocksAPI

extension MainTabBar {
    class ViewModel {
        init() {
            
        }
        
        func start() async {
            let apple1dChart = try! await XCAStocksAPI().fetchQuotes(symbols: "APPL")
            print(apple1dChart)
        }
    }
}

struct MainTabBar: View {
    let vn = ViewModel()
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
    }
}

struct MainTabBar_Previews: PreviewProvider {
    static var previews: some View {
        MainTabBar()
    }
}

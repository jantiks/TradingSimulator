//
//  ContentView.swift
//  TradingSimulator
//
//  Created by Tigran on 19.03.23.
//

import SwiftUI

struct MainTabBar: View {
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

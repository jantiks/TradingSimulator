//
//  MarketsView.swift
//  TradingSimulator
//
//  Created by Tigran on 28.03.23.
//

import SwiftUI

extension MarketsView {
    private class ViewModel: ObservableObject {
        @Published var searchText: String = ""
        @Published var searchItems = [
            SimpleStockModel(id: UUID().uuidString, symbol: StockSymbol(ticker: "BTC", name: "Bitcoin", exchange: "Test"), price: 140, gains: 10, image: ""),
            SimpleStockModel(id: UUID().uuidString, symbol: StockSymbol(ticker: "BTC", name: "Bitcoin", exchange: "Test"), price: 140, gains: 10, image: ""),
            SimpleStockModel(id: UUID().uuidString, symbol: StockSymbol(ticker: "BTC", name: "Bitcoin", exchange: "Test"), price: 140, gains: 10, image: ""),
            SimpleStockModel(id: UUID().uuidString, symbol: StockSymbol(ticker: "BTC", name: "Bitcoin", exchange: "Test"), price: 140, gains: 10, image: ""),
            SimpleStockModel(id: UUID().uuidString, symbol: StockSymbol(ticker: "BTC", name: "Bitcoin", exchange: "Test"), price: 140, gains: 10, image: ""),
            SimpleStockModel(id: UUID().uuidString, symbol: StockSymbol(ticker: "BTC", name: "Bitcoin", exchange: "Test"), price: 140, gains: 10, image: "")]
    }
}

struct MarketsView: View {
    
    @StateObject private var vm = ViewModel()
    
    var body: some View {
        VStack {
            Text("Live Prices")
                .font(.headline)
                .fontWeight(.heavy)
                .padding(.top, 10)
                .padding(.bottom, 20)
            SearchBar(searchText: $vm.searchText)
            List(vm.searchItems) {
                StockItemView(stock: $0)
                    .listRowInsets(EdgeInsets(top: 10, leading: 0, bottom: 10, trailing: 0))
            }
            .listStyle(PlainListStyle())
            Spacer()
        }
    }
}

struct MarketsView_Previews: PreviewProvider {
    static var previews: some View {
        MarketsView()
    }
}

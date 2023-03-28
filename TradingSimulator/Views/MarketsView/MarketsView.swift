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
    }
}

struct MarketsView: View {
    
    @StateObject private var vm = ViewModel()
    
    var body: some View {
        VStack() {
            Text("Live Prices")
                .font(.headline)
                .fontWeight(.heavy)
                .padding(.top, 10)
                .padding(.bottom, 20)
            SearchBar(searchText: $vm.searchText)
            Spacer()
        }
    }
}

struct MarketsView_Previews: PreviewProvider {
    static var previews: some View {
        MarketsView()
    }
}

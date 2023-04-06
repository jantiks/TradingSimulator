//
//  MarketsView.swift
//  TradingSimulator
//
//  Created by Tigran on 28.03.23.
//

import SwiftUI

extension MarketsView {
    private class ViewModel: ObservableObject {
        private var stockSymbols = (try? StockSymbolDataProvider.shared.getStockSymbols()) ?? []
        private var currentSearch: DispatchWorkItem?
        @Published var searchText: String = "" {
            didSet {
                // Cancel the previous search task
                currentSearch?.cancel()

                // Create a new search task
                var searchTask: DispatchWorkItem?
                searchTask = DispatchWorkItem { [weak self] in
                    guard let searchItems = self?.fuzzySearch(query: self?.searchText ?? "") else { return }
                    guard searchTask?.isCancelled == false else { return }
                    DispatchQueue.main.async {
                        self?.searchItems = searchItems
                    }
                }

                // Start the new search task on a global queue
                DispatchQueue.global(qos: .userInteractive).async(execute: searchTask!)

                // Store the current search task
                currentSearch = searchTask
            }
        }
        @Published var searchItems: [SimpleStockModel] = []
        
        
        func fuzzySearch(query: String) -> [SimpleStockModel] {
            var results: [SimpleStockModel] = []
            let query = query.lowercased()
            
            for stockSymbol in stockSymbols {
                let tickerMatch = stockSymbol.symbol.ticker.lowercased().contains(query)
                let nameMatch = stockSymbol.symbol.name.lowercased().contains(query)
                
                if tickerMatch || nameMatch {
                    results.append(stockSymbol)
                } else {
                    // Calculate the Levenshtein distance between the query and the company name
                    let distance = levDis(query, stockSymbol.symbol.name.lowercased())
                    if distance <= 2 {
                        results.append(stockSymbol)
                    }
                }
            }
            
            // Sort the results by relevance (exact matches first, then fuzzy matches)
            results.sort { result1, result2 in
                let ticker1Match = result1.symbol.ticker.lowercased() == query
                let ticker2Match = result2.symbol.ticker.lowercased() == query
                
                if ticker1Match && !ticker2Match {
                    return true
                } else if !ticker1Match && ticker2Match {
                    return false
                } else {
                    let name1Distance = levDis(query, result1.symbol.name.lowercased())
                    let name2Distance = levDis(query, result2.symbol.name.lowercased())
                    return name1Distance < name2Distance
                }
            }
            
            return results
        }
        
        func levDis(_ w1: String, _ w2: String) -> Int {
            let empty = [Int](repeating:0, count: w2.count)
            var last = [Int](0...w2.count)

            for (i, char1) in w1.enumerated() {
                var cur = [i + 1] + empty
                for (j, char2) in w2.enumerated() {
                    cur[j + 1] = char1 == char2 ? last[j] : min(last[j], last[j + 1], cur[j]) + 1
                }
                last = cur
            }
            return last.last!
        }

        
        private func updateFilters() {
            let lowerCasedText = searchText.lowercased()
            let lowerCasedTextCount = lowerCasedText.count

            let filtered = stockSymbols
                .filter({
                    return $0.symbol.ticker.lowercased().contains(lowerCasedText) || $0.symbol.name.lowercased().contains(lowerCasedText)
                })
                .sorted(by: { (a, b) in
                    
                    let aMatchRange = a.symbol.name.range(of: searchText, options: [.caseInsensitive, .diacriticInsensitive])
                    let bMatchRange = b.symbol.name.range(of: searchText, options: [.caseInsensitive, .diacriticInsensitive])
                    
                    let aTickerRange = a.symbol.ticker.range(of: searchText, options: [.caseInsensitive, .diacriticInsensitive])
                    let bTickerRange = b.symbol.ticker.range(of: searchText, options: [.caseInsensitive, .diacriticInsensitive])
                    if lowerCasedTextCount <= 3 {
                        // iata priority
                        if aTickerRange?.lowerBound == a.symbol.ticker.startIndex && bTickerRange?.lowerBound == b.symbol.ticker.startIndex {
                            return aTickerRange?.upperBound ?? String.Index(utf16Offset: 0, in: "") < bTickerRange?.upperBound ?? String.Index(utf16Offset: 0, in: "")
                        } else if aTickerRange?.lowerBound == a.symbol.ticker.startIndex {
                            return true
                        } else if bTickerRange?.lowerBound == b.symbol.ticker.startIndex {
                            return false
                        } else if aMatchRange?.lowerBound == a.symbol.name.startIndex && bMatchRange?.lowerBound == b.symbol.name.startIndex {
                            return aMatchRange?.upperBound ?? String.Index(utf16Offset: 0, in: "") < aMatchRange?.upperBound ?? String.Index(utf16Offset: 0, in: "")
                        } else if aMatchRange?.lowerBound == a.symbol.name.startIndex {
                            return true
                        } else if bMatchRange?.lowerBound == b.symbol.name.startIndex {
                            return false
                        } else {
                            return a.symbol.name < b.symbol.name
                        }
                    } else {
                        // city name priority
                        if aMatchRange?.lowerBound == a.symbol.name.startIndex && bMatchRange?.lowerBound == b.symbol.name.startIndex {
                            return aMatchRange?.upperBound ?? String.Index(utf16Offset: 0, in: "") < aMatchRange?.upperBound ?? String.Index(utf16Offset: 0, in: "")
                        } else if aTickerRange?.lowerBound == a.symbol.ticker.startIndex && bMatchRange?.lowerBound == b.symbol.ticker.startIndex {
                            return aTickerRange?.upperBound ?? String.Index(utf16Offset: 0, in: "") < bTickerRange?.upperBound ?? String.Index(utf16Offset: 0, in: "")
                        } else if aMatchRange?.lowerBound == a.symbol.name.startIndex || aTickerRange?.lowerBound == a.symbol.ticker.startIndex {
                            return true
                        } else if bMatchRange?.lowerBound == b.symbol.name.startIndex || bTickerRange?.lowerBound == b.symbol.ticker.startIndex {
                            return false
                        } else {
                            return a.symbol.name < b.symbol.name
                        }
                    }
                })
            searchItems = Array(filtered.prefix(20))
        }
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

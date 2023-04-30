//
//  TradeStockView.swift
//  TradingSimulator
//
//  Created by Tigran on 23.04.23.
//

import SwiftUI
import Charts
import XCAStocksAPI
import DomainGesture
import Introspect
import Combine

extension Indicator: Identifiable {
    public var id: String {
        return UUID().uuidString
    }
}

extension TradeStockView {
    private class ViewModel: NSObject, ObservableObject, UIScrollViewDelegate {

        @Published var stock: SimpleStockModel
        @Published var chartYDomain: ClosedRange<Double> = 168.8...169.8
        @Published var defaultWidth: Double = 6000
        private var previousOffset: Double = 0
        private var scrollDistance: Double = 0
        private var delegateSet = false
        private var scrollView: UIScrollView? = nil
        
        private var cancalables: [AnyCancellable] = []
        
        init(stock: SimpleStockModel) {
            self.stock = stock
            super.init()
            stock.$chartData
            .sink { [weak self] newValue in
                guard let scrollView = self?.scrollView else { return }
                self?.updateChartYDomain(scrollView)
            }
            .store(in: &cancalables)
        }
        
        func introspectScrollView(_ scrollView: UIScrollView) {
            guard !delegateSet else { return }
            scrollView.delegate = self
            let bottomOffset = CGPoint(x:  scrollView.contentSize.width - scrollView.bounds.width + scrollView.contentInset.right, y: 0)
            scrollView.setContentOffset(bottomOffset, animated: false)
            self.scrollView = scrollView
            delegateSet = true
            updateChartYDomain(scrollView)
        }
        
        func scrollViewDidScroll(_ scrollView: UIScrollView) {
            guard let indicators = stock.chartData?.indicators else {
                return
            }
            if (defaultWidth / Double(indicators.count)) > scrollDistance {
                scrollDistance = 0
                updateChartYDomain(scrollView)
            } else {
                scrollDistance += scrollView.contentOffset.x - previousOffset
            }
            
            previousOffset = scrollView.contentOffset.x
        }
        
        func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
            guard let minMaxValues = getMinMaxIndiciatorValues(scrollView) else { return }
            let minNumber = minMaxValues.0
            let maxNumber = minMaxValues.1
            
            DispatchQueue.main.async {
                self.chartYDomain = (minNumber / 1.001)...(maxNumber * 1.001)
            }
        }
        
        private func updateChartYDomain(_ scrollView: UIScrollView) {
            guard let minMaxValues = getMinMaxIndiciatorValues(scrollView) else { return }
            let minNumber = minMaxValues.0
            let maxNumber = minMaxValues.1
            
            if chartYDomain.lowerBound <= minNumber && chartYDomain.upperBound >= maxNumber {
                return
            }
            DispatchQueue.main.async {
                if self.chartYDomain.lowerBound <= minNumber {
                    self.chartYDomain = self.chartYDomain.lowerBound...(maxNumber * 1.001)
                } else if self.chartYDomain.upperBound >= minNumber {
                    self.chartYDomain = (minNumber / 1.001)...self.chartYDomain.upperBound
                } else {
                    self.chartYDomain = (minNumber / 1.001)...(maxNumber * 1.001)
                }
            }
        }
        
        private func getMinMaxIndiciatorValues(_ scrollView: UIScrollView) -> (Double, Double)? {
            guard let indicators = stock.chartData?.indicators else { return nil }
            var currentWindowStart = Double(scrollView.contentOffset.x - scrollView.bounds.width)
            if currentWindowStart < 0 {
                currentWindowStart = 0
            }
            let startIndicatorPosition = Int(currentWindowStart * Double(indicators.count) / defaultWidth)
            let endIndicatorPostition = Int(Double(startIndicatorPosition) + scrollView.bounds.width /  (defaultWidth / Double(indicators.count)))
            
            let minNumber = (indicators[startIndicatorPosition...endIndicatorPostition].map({ $0.low }).min() ?? 0.0)
            let maxNumber = (indicators[startIndicatorPosition...endIndicatorPostition].map({ $0.high }).max() ?? 0.0)
            
            return (minNumber, maxNumber)
        }
    }
}

struct TradeStockView: View {
    @ObservedObject private var vm: ViewModel
    @StateObject private var stock: SimpleStockModel
    
    init(stock: SimpleStockModel) {
        _stock = StateObject(wrappedValue: stock)
        _vm = ObservedObject(wrappedValue: ViewModel(stock: stock))
    }
    
    var body: some View {
        NavigationView {
            VStack {
                Text(vm.stock.symbol.ticker)
                    .font(.inputBold)
                Text(vm.stock.symbol.name)
                    .foregroundColor(Color.theme.accent.opacity(0.6))
                Spacer()
                
                ScrollView(.horizontal) {
                    Chart(vm.stock.chartData?.indicators ?? [], id: \.timestamp) { stock in
                        RectangleMark(
                            x: .value("Date", stock.timestamp),
                            yStart: .value("Low", stock.low),
                            yEnd: .value("High", stock.high),
                            width: 1
                        )
                        .foregroundStyle(stock.open < stock.close ? .red : .green)
                        
                        RectangleMark(
                            x: .value("Date", stock.timestamp),
                            yStart: .value("Low", stock.open),
                            yEnd: .value("High", stock.close),
                            width: 6
                        )
                        .foregroundStyle(stock.open < stock.close ? .red : .green)
                    }
//                    .animation(.linear)
                    .chartXAxis {
                        AxisMarks(values: .stride(by: .minute, count: 4, roundLowerBound: true, roundUpperBound: true)) { date in
                            AxisValueLabel(format: .dateTime.hour().minute())
                        }
                    }
                    //                Date(timeIntervalSinceReferenceDate: 704404200)...Date(timeIntervalSinceReferenceDate: 704404800)
                    //                        .chartXScale(domain: (stock.chartData?.indicators[340].timestamp ?? Date())...(stock.chartData?.indicators.last?.timestamp ?? Date()))
                    .chartYScale(domain: withAnimation { vm.chartYDomain })
                    .frame(width: vm.defaultWidth)
                }
                .scrollIndicators(.hidden)
                .introspectScrollView { scrollView in
                    vm.introspectScrollView(scrollView)
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
            await vm.stock.updateChartData()
        }
    }
}

struct TradeStockView_Previews: PreviewProvider {
    static var previews: some View {
        TradeStockView(stock: .init(symbol: .init(ticker: "AAPL", name: "Apple inc", marketCap: 120), price: 120, gains: 10, image: ""))
    }
}

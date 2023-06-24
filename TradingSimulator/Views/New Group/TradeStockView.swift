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
        @Published var chartYDomain: ClosedRange<Double>? = nil
        @Published var defaultWidth: Double = 6000
        private var previousOffset: Double = 0
        private var scrollDistance: Double = 0
        private var delegateSet = false
        var scrollView: UIScrollView? = nil
        let trailingPadding: CGFloat = 30
        let leadingPadding: CGFloat = 10
        
        private var cancalables: [AnyCancellable] = []
        
        init(stock: SimpleStockModel) {
            self.stock = stock
            super.init()
            stock.$chartData
            .sink { [weak self] newValue in
                guard let newValue = newValue else { return }
                self?.defaultWidth = Double(newValue.indicators.count) * 15.4
                
                DispatchQueue.main.async {
                    guard let scrollView = self?.scrollView else { return }
                    self?.updateChartYDomain(scrollView, soft: false)
                }
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
            updateChartYDomain(scrollView, soft: false)
        }
                
        func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
            updateChartYDomain(scrollView, soft: false)
        }
        
        func executeTasks() async {
            await stock.updateChartData()
            try? YahooFinanceWebSocket.shared.addSubscribers([WebsocketSubscriber(symbol: stock.symbol.ticker, updateAction: { stock in
                
            })])
        }
        
        private func updateChartYDomain(_ scrollView: UIScrollView, soft: Bool) {
            guard let minMaxValues = getMinMaxIndiciatorValues(scrollView) else { return }
            let minNumber = minMaxValues.0
            let maxNumber = minMaxValues.1
            
            if soft, let chartYDomain = chartYDomain, chartYDomain.lowerBound <= minNumber && chartYDomain.upperBound >= maxNumber {
                return
            }
            DispatchQueue.main.async {
                if soft, let chartYDomain = self.chartYDomain {
                    if chartYDomain.lowerBound <= minNumber {
                        self.chartYDomain = chartYDomain.lowerBound...(maxNumber * 1.001)
                    } else if chartYDomain.upperBound >= minNumber {
                        self.chartYDomain = (minNumber / 1.001)...chartYDomain.upperBound
                    } else {
                        self.chartYDomain = (minNumber / 1.001)...(maxNumber * 1.001)
                    }
                } else  {
                    self.chartYDomain = (minNumber / 1.001)...(maxNumber * 1.001)
                }
            }
        }
        
        private func getMinMaxIndiciatorValues(_ scrollView: UIScrollView) -> (Double, Double)? {
            guard let indicators = stock.chartData?.indicators, defaultWidth != 0 else { return nil }
            var currentWindowStart = Double(scrollView.contentOffset.x)
            if currentWindowStart < 0 {
                currentWindowStart = 0
            }
            let startIndicatorPosition = max(Int(currentWindowStart * Double(indicators.count) / defaultWidth), 0)
            let endIndicatorPostition = min(Int(Double(startIndicatorPosition) + scrollView.bounds.width /  (defaultWidth / Double(indicators.count))) + 5, indicators.count - 1)
            
            let minNumber = (indicators[startIndicatorPosition...endIndicatorPostition].map({ $0.low }).min() ?? 0.0)
            let maxNumber = (indicators[startIndicatorPosition...endIndicatorPostition].map({ $0.high }).max() ?? 0.0)
            
            return (minNumber, maxNumber)
        }
    }
}

struct TradeStockView: View {
    @ObservedObject private var vm: ViewModel
    @StateObject private var stock: SimpleStockModel
    @State var chartYDomain: ClosedRange<Double> = 0...0
    @State var yAxisRange: Range<Int>? = nil
    @State var yAxisItems = [YAxisItem]()
    
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
                    .chartXAxis {
                        AxisMarks(values: .stride(by: .minute, count: 4, roundLowerBound: true, roundUpperBound: true)) { date in
                            AxisValueLabel(format: .dateTime.hour().minute())
                        }
                    }
                    .chartYScale(domain: chartYDomain)
                    .chartYAxis(.hidden)
                    .padding(.trailing, vm.trailingPadding)
                    .padding(.leading, vm.leadingPadding)
                    .frame(width: vm.defaultWidth)
                }
                .overlay(alignment: .trailing, content: {
                    VStack(alignment: .leading, spacing: 5) {
                        ForEach(yAxisItems, content: { value in
                                    Text("\(String(format: "%.2f", value.value))")
                                        .foregroundColor(Color.theme.accent)
                                        .font(.system(size: 12))
                                        .padding(.leading, 5)
                                    Spacer()
                            })
                    }
                    .frame(width: 60, height: vm.scrollView?.bounds.height ?? 0.0)
                    .background(Color.theme.background)
                })
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
                            print("BUY")
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
            
        }
        .onChange(of: vm.chartYDomain, perform: { newValue in
            guard let newValue = newValue else { return }
            let numOfItems = Int(Double(vm.scrollView?.bounds.height ?? 0.0) / 40)

            withAnimation(.easeInOut(duration: 0.3)) {
                self.chartYDomain = newValue
                
                var newYAxisItems = [YAxisItem]()

                for i in 0...numOfItems {
                    newYAxisItems.append(
                        YAxisItem(
                            value: newValue.lowerBound + (Double(i) * ((newValue.upperBound - newValue.lowerBound) / Double(numOfItems)))
                        )
                    )
                }
                yAxisItems = newYAxisItems.reversed()
            }
        })
        .task {
            await vm.executeTasks()
        }
    }
}

struct TradeStockView_Previews: PreviewProvider {
    static var previews: some View {
        TradeStockView(stock: .init(symbol: .init(ticker: "AAPL", name: "Apple inc", marketCap: 120), price: 120, gains: 10, image: ""))
    }
}

struct YAxisItem: Identifiable {
    let id: UUID
    let value: Double
    
    init(id: UUID = UUID(), value: Double) {
        self.id = id
        self.value = value
    }
}

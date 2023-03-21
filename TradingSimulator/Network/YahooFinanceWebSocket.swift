//
//  YahooFianceWebsocket.swift
//  TradingSimulator
//
//  Created by Tigran on 20.03.23.
//

import Foundation
import Starscream

struct SubscribeModel: Encodable {
    let subscribe: [String]
}

struct UnSubscribeModel: Encodable {
    let unsubscribe: [String]
}

class WebsocketSubscriber {
    let id: UUID
    let symbol: String
    let updateAction: (StockModel) -> Void
    
    init(symbol: String, updateAction: @escaping (StockModel) -> Void) {
        id = UUID()
        self.symbol = symbol
        self.updateAction = updateAction
    }
}

enum YahooFinanceWebSocketError: Error {
    case notConnected
}

class YahooFinanceWebSocket: WebSocketDelegate {
    
    static let shared = YahooFinanceWebSocket()
    private var isConnected = false
    
    private var socket: WebSocket?
    private var subscribers: [WebsocketSubscriber] = []
    
    private init() { }
    
    func connect() {
        var request = URLRequest(url: URL(string: "wss://streamer.finance.yahoo.com")!)
        request.timeoutInterval = 5
        let pinner = FoundationSecurity(allowSelfSigned: true)
        socket = WebSocket(request: request, certPinner: pinner)
        socket?.delegate = self
        socket?.connect()
    }
    
    func addSubscribers(_ subscribers: [WebsocketSubscriber]) throws {
        guard isConnected else { throw YahooFinanceWebSocketError.notConnected }

        subscribeToSymbol(subscribers.map({ $0.symbol }))
        self.subscribers.append(contentsOf: subscribers)
    }
    
    func removeSubscriber(with id: UUID) throws {
        guard isConnected else { throw YahooFinanceWebSocketError.notConnected }
        
        let removedElems = subscribers.filter({ $0.id == id })
        subscribers.removeAll(where: { $0.id == id })
        disconnect(removedElems.map({ $0.symbol }))
    }
    
    func disconnect() {
        socket?.disconnect()
    }
    
    func didReceive(event: WebSocketEvent, client: WebSocket) {
        switch event {
        case .connected(let headers):
            isConnected = true
            print("websocket is connected: \(headers)")
            self.subscribeToSymbol(["THB=X", "BTC", "ETC", "USDT"])
        case .disconnected(let reason, let code):
            isConnected = false
            print("websocket is disconnected: \(reason) with code: \(code)")
        case .text(let string):
            if let decodedData = try? ProtobufDecoder().decode(type: PricingData.self, base64EncodedString: string) {
                subscribers.forEach({
                    if $0.symbol == decodedData.id {
                        $0.updateAction(StockModel(from: decodedData))
                    }
                })
            }
        case .binary(let data):
            print("Received data: \(data.count)")
        case .ping(_):
            break
        case .pong(_):
            break
        case .viabilityChanged(_):
            break
        case .reconnectSuggested(_):
            break
        case .cancelled:
            isConnected = false
        case .error(let error):
            isConnected = false
            handleError(error)
        }
    }
    
    func websocketDidReceiveMessage(socket: WebSocketClient, text: String) {
        let json = try! JSONSerialization.jsonObject(with: text.data(using: .utf8)!, options: []) as! [String: Any]
        if json["type"] as? String == "ping" {
            let message = ["type": "pong"]
            let json = try! JSONSerialization.data(withJSONObject: message, options: [])
            socket.write(data: json)
        } else {
            print(json)
        }
    }
    
    func websocketDidReceiveData(socket: WebSocketClient, data: Data) {}
    
    private func subscribeToSymbol(_ symbols: [String]) {
       let model = SubscribeModel(subscribe: symbols)
       let json = try! JSONEncoder().encode(model)
       socket?.write(stringData: json, completion: nil)
    }
       
    private func disconnect(_ symbols: [String]) {
        let model = UnSubscribeModel(unsubscribe: symbols)
        let json = try! JSONEncoder().encode(model)
        socket?.write(stringData: json, completion: nil)
    }
    
    private func handleError(_ error: Error?) {
        print(error)
    }
}

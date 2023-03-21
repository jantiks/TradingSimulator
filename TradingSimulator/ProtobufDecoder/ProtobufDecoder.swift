//
//  ProtobufDecoder.swift
//  TradingSimulator
//
//  Created by Tigran on 21.03.23.
//

import Foundation
import SwiftProtobuf

enum ProtobufDecoderError: Error {
    case failure
}

struct ProtobufDecoder {
    func decode<T: SwiftProtobuf.Message>(type: T.Type, base64EncodedString: String) throws -> T {
        if let decodedData = Data(base64Encoded: base64EncodedString) {
            let decodedObject = try! T.init(serializedData: decodedData)
            return decodedObject
        }
        
        throw ProtobufDecoderError.failure
    }
}

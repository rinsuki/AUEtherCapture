//
//  File.swift
//  
//
//  Created by user on 2021/03/01.
//

import Foundation

struct UDPPair: Equatable, Hashable {
    var srcAddress: IPv4.Address
    var srcPort: UInt16
    
    var dstAddress: IPv4.Address
    var dstPort: UInt16
    
    func reversed() -> UDPPair {
        return .init(srcAddress: dstAddress, srcPort: dstPort, dstAddress: srcAddress, dstPort: srcPort)
    }
}

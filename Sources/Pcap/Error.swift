//
//  File.swift
//  
//
//  Created by user on 2021/02/27.
//

import Foundation
import libpcap

public enum PcapError: Error {
    case withString(String)
    case failedToCompileBPF
    case failedToSetBPF
}

func withErrBuf<T>(_ callback: (inout [Int8]) -> T?) throws -> T {
    var errbuf = [Int8].init(repeating: 0, count: Int(PCAP_ERRBUF_SIZE))
    if let result = callback(&errbuf) {
        return result
    } else {
        throw PcapError.withString(String(cString: errbuf))
    }
}

//
//  File.swift
//  
//
//  Created by user on 2021/02/27.
//

import Foundation

public struct Timestamp: CustomStringConvertible {
    public var seconds: Int
    // microseconds are 0 ~ 1_000_000, so it should Int32
    public var usecs: Int32
    
    public var double: Double {
        Double(seconds) + (Double(usecs) / 1_000_000)
    }
    
    public var description: String {
        String(format: "%.06f", double)
    }
    
    init(_ timeval: timeval) {
        seconds = .init(timeval.tv_sec)
        usecs = .init(timeval.tv_usec)
    }
}

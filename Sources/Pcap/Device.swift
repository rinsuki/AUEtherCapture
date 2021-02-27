//
//  Device.swift
//  
//
//  Created by user on 2021/02/27.
//

import Foundation
import libpcap

public struct Device {
    public let name: String
    public let description: String?
    
    init(from device: pcap_if_t) {
        name = String(cString: device.name)
        if let desc = device.description {
            description = String(cString: desc)
        } else {
            description = nil
        }
    }
    
    public static func all() -> [Device] {
        var errbuf = [Int8].init(repeating: 0, count: Int(PCAP_ERRBUF_SIZE))
        var devices: UnsafeMutablePointer<pcap_if_t>? = nil
        var result: [Device] = []
        pcap_findalldevs(&devices, &errbuf)
        while let device = devices?.pointee {
            result.append(.init(from: device))
            devices = device.next
        }
        pcap_freealldevs(devices)
        return result
    }
}

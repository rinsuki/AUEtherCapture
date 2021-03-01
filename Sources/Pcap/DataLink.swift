//
//  File.swift
//  
//
//  Created by user on 2021/03/01.
//

import Foundation
import libpcap

public struct DataLink: CustomStringConvertible, Equatable {
    public static let ethernet = DataLink(value: DLT_EN10MB)
    
    public var value: Int32
    
    public var description: String {
        return String(cString: pcap_datalink_val_to_name(value))
    }
}

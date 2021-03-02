//
//  UDP.swift
//  
//
//  Created by user on 2021/03/01.
//

import Foundation
import BinaryReader

struct UDP {
    var src: UInt16
    var dst: UInt16
    var checksum: UInt16
    var data: Data
    
    init(from reader: inout BinaryReader) {
        src = reader.uint16()
        dst = reader.uint16()
        // このlengthはheaderの分も含んでいるので、ヘッダーの分を引く必要がある
        let len = reader.uint16() - 8
        checksum = reader.uint16()
        data = reader.bytes(count: UInt(len))
    }
}

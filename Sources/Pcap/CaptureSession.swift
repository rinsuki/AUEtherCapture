//
//  CaptureSession.swift
//  
//
//  Created by user on 2021/02/27.
//
import Foundation
#if os(Windows)
// for timeval struct (in winsock)
import WinSDK
typealias timeval = TIMEVAL
#endif
import libpcap

public class CaptureSession: IteratorProtocol, CustomStringConvertible {
    public typealias Element = (Timestamp, Data)

    private enum Source {
        case device(Device)
        case file(URL)
    }
    private var source: Source
    public private(set) var finished: Bool = false
    private var nativeHandler: OpaquePointer
    public var datalink: DataLink {
        return .init(value: pcap_datalink(nativeHandler))
    }
    
    public var description: String {
        let src: String
        switch source {
        case .device(let device):
            if let desc = device.description {
                src = "Device,\(device.name) (\(desc))"
            } else {
                src = "Device,\(device.name)"
            }
        case .file(let url):
            src = "File,\(url.path)"
        }
        return "<\(String(describing: Self.self)) source=\(src)>"
    }
    
    deinit {
        pcap_close(nativeHandler)
    }
    
    public init(device: Device, promisc: Bool = false) throws {
        self.source = .device(device)
        self.nativeHandler = try withErrBuf { pcap_open_live(device.name, 1500, promisc ? 1 : 0, 16, &$0) }
    }
    
    public init(file: URL) throws {
        guard file.isFileURL else {
            preconditionFailure("file parameter should file:// URL")
        }
        self.source = .file(file)
        self.nativeHandler = try withErrBuf { pcap_open_offline(file.path, &$0) }
    }
    
    public func setBPF(filter: String) throws {
        var program = bpf_program()
        if pcap_compile(nativeHandler, &program, filter, 0, 0) == -1 {
            throw PcapError.failedToCompileBPF
        }
        if pcap_setfilter(nativeHandler, &program) == -1 {
            throw PcapError.failedToSetBPF
        }
    }
    
    public func next() -> Element? {
        return next(returnIfTimeout: false)
    }

    public func next(returnIfTimeout: Bool) -> Element? {
        var header = UnsafeMutablePointer<pcap_pkthdr>(nil as OpaquePointer?)
        var data = UnsafePointer<u_char>(nil as OpaquePointer?)
        while true {
            let result = pcap_next_ex(nativeHandler, &header, &data)
            switch result {
            case 1: // success
                guard let header = header?.pointee, let data = data else {
                    fatalError("pcap_next_ex returns 1 (success), but header or data is nil")
                }
                return (Timestamp(header.ts), Data(bytes: data, count: Int(header.caplen)))
            case 0: // timeout
                if returnIfTimeout {
                    return nil
                }
                continue
            case -1, -2: // error / EOF
                finished = true
                return nil
            default: // WTF
                fatalError("Unknown pcap_next_ex return code: \(result)")
            }
        }
    }
}

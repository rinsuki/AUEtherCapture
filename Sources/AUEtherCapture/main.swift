import Foundation
import Pcap
import ArgumentParser
import Regex
import BinaryReader

struct CLI: ParsableCommand {
    @Option(name: .long, help: "IP Address of client (IPv4).")
    var clientIP: IPv4.Address
    
    @Option(name: .long, help: "Network Interface for packet capture.")
    var networkInterface: String?
    
    @Flag(name: .long, help: "Show List of Network Interface that available.")
    var listNetworkInterface: Bool = false
    
    func run() throws {
        if listNetworkInterface {
            print("Available (and compatible) Network Interfaces: ")
            var notAvailableInterfaces = [Device]()
            for device in Pcap.Device.all() {
                if let datalink = try? Pcap.CaptureSession(device: device).datalink, datalink != .ethernet {
                    notAvailableInterfaces.append(device)
                    continue
                }
                if let desc = device.description {
                    print("\(device.name)\t\(desc)")
                } else {
                    print(device.name)
                }
            }
            if notAvailableInterfaces.count > 0 {
                print()
                print("Incompatible Network Interfaces: \(notAvailableInterfaces.map { $0.name }.joined(separator: ", "))")
            }
            print()
            return
        }
        
        func createCaptureSession(prefer: String?) throws -> Pcap.CaptureSession? {
            let devices = Pcap.Device.all()
            if let prefer = prefer, let device = devices.first(where: { $0.name == prefer }) {
                return try Pcap.CaptureSession(device: device, timeoutMillisec: 50)
            }
            for device in Pcap.Device.all() {
                let session = try Pcap.CaptureSession(device: device, timeoutMillisec: 50)
                if session.datalink != .ethernet {
                    print("Skip \(device) because this device's datalink is not ethernet (\(session.datalink))")
                    continue
                }
                return session
            }
            return nil
        }

        guard let session = try createCaptureSession(prefer: networkInterface) else {
            print("Failed to find network interface")
            Foundation.exit(1)
        }

        let auports = [22023, 22123, 22223, 22323, 22423, 22523, 22623, 22723, 22823, 22923]
        let bpf = "host \(clientIP.string) and udp and (port \(auports.map { String($0) }.joined(separator: " or ")))"
        print(bpf)
        try session.setBPF(filter: bpf)

        print("session started", session)

        var state = CaptureState()
        while let (ts, packet) = session.next() {
            let ethernet = Ethernet(from: packet)
            if case .ipv4(let ipv4) = ethernet.content, case .udp(let udp) = ipv4.content {
                state.timestamp = ts.double
                state.handle(data: udp.data, pair: .init(srcAddress: ipv4.src, srcPort: udp.src, dstAddress: ipv4.dst, dstPort: udp.dst))
            }
        }
    }
}

extension IPv4.Address: ExpressibleByArgument {
    init?(argument: String) {
        guard let match = Regex("^([0-9]+)\\.([0-9]+)\\.([0-9]+)\\.([0-9]+)$").firstMatch(in: argument) else {
            return nil
        }
        value = (
            UInt8(match.captures[0]!)!,
            UInt8(match.captures[1]!)!,
            UInt8(match.captures[2]!)!,
            UInt8(match.captures[3]!)!
        )
    }
}

CLI.main()

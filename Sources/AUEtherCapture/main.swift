import Foundation
import Pcap
import ArgumentParser
import Regex

struct CLI: ParsableCommand {
    @Option(name: .long, help: "IP Address of client (IPv4).")
    var clientIP: IPv4.Address
    
    func run() throws {
        func createCaptureSession() throws -> Pcap.CaptureSession? {
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

        guard let session = try createCaptureSession() else {
            print("Failed to find network interface")
            Foundation.exit(1)
        }

        let auports = [22023, 22123, 22223, 22323, 22423, 22523, 22623, 22723, 22823, 22923]
        let bpf = "host \(clientIP.string) and udp and (port \(auports.map { String($0) }.joined(separator: " or ")))"
        print(bpf)
        try session.setBPF(filter: bpf)

        print("session started", session)

        while let (ts, packet) = session.next() {
            let ethernet = Ethernet(from: packet)
            print(ts.seconds, ethernet)
            if case .ipv4(let ipv4) = ethernet.content, case .udp(let udp) = ipv4.content {
                print(udp.data)
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

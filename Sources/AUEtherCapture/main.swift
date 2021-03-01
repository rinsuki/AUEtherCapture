import Foundation
import Pcap
//print(Pcap.Device.all())

let session = try Pcap.CaptureSession(device: Pcap.Device.all().filter { $0.name != "\\Device\\NPF_Loopback" && $0.name != "lo0" }.first!)

print("session started", session)

while let (ts, packet) = session.next() {
    let ethernet = Ethernet(from: packet)
    print(ts.seconds, ethernet)
}


import Foundation
import Pcap
//print(Pcap.Device.all())

let session = try Pcap.CaptureSession(device: Pcap.Device.all().first!)

print("session started", session)

while let (ts, packet) = session.next() {
    print(ts, packet)
}

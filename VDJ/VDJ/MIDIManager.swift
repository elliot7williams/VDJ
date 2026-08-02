import Foundation
import CoreMIDI

class MIDIManager: ObservableObject {
    @Published var connectedDevices: [String] = []
    @Published var isReceivingMIDI = false
    
    private var midiClient = MIDIClientRef()
    private var inputPort = MIDIPortRef()
    
    init() {
        setupMIDI()
    }
    
    private func setupMIDI() {
        var status = OSStatus(noErr)
        
        // Create MIDI client
        status = MIDIClientCreateWithBlock("VDJMIDIClient" as CFString, &midiClient) { _ in
            // MIDI system change notification
            DispatchQueue.main.async {
                self.scanForDevices()
            }
        }
        
        guard status == noErr else {
            print("Error creating MIDI client: \(status)")
            return
        }
        
        // Create input port
        status = MIDIInputPortCreateWithBlock(midiClient, "VDJInputPort" as CFString, &inputPort) { packetList, _ in
            self.processMIDIPacketList(packetList)
        }
        
        guard status == noErr else {
            print("Error creating MIDI input port: \(status)")
            return
        }
        
        scanForDevices()
    }
    
    func scanForDevices() {
        connectedDevices.removeAll()
        
        let sourceCount = MIDIGetNumberOfSources()
        for i in 0..<sourceCount {
            let source = MIDIGetSource(i)
            var name: Unmanaged<CFString>?
            let status = MIDIObjectGetStringProperty(source, kMIDIPropertyName, &name)
            
            if status == noErr, let deviceName = name?.takeRetainedValue() as String? {
                connectedDevices.append(deviceName)
                
                // Connect to the source
                MIDIPortConnectSource(inputPort, source, nil)
            }
        }
    }
    
    private func processMIDIPacketList(_ packetList: UnsafePointer<MIDIPacketList>) {
        let packets = packetList.pointee
        var packet = packets.packet
        
        for _ in 0..<packets.numPackets {
            processMIDIPacket(packet)
            packet = MIDIPacketNext(&packet).pointee
        }
    }
    
    private func processMIDIPacket(_ packet: MIDIPacket) {
        let data = withUnsafeBytes(of: packet.data) { bytes in
            Array(bytes.prefix(Int(packet.length)))
        }
        
        guard data.count >= 3 else { return }
        
        let status = data[0] & 0xF0
        let channel = data[0] & 0x0F
        
        DispatchQueue.main.async {
            self.isReceivingMIDI = true
            
            // Reset the flag after a short delay
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                self.isReceivingMIDI = false
            }
        }
        
        switch status {
        case 0x90: // Note On
            let note = data[1]
            let velocity = data[2]
            handleNoteOn(note: note, velocity: velocity, channel: channel)
            
        case 0x80: // Note Off
            let note = data[1]
            handleNoteOff(note: note, channel: channel)
            
        case 0xB0: // Control Change
            let controller = data[1]
            let value = data[2]
            handleControlChange(controller: controller, value: value, channel: channel)
            
        default:
            break
        }
    }
    
    private func handleNoteOn(note: UInt8, velocity: UInt8, channel: UInt8) {
        // Handle MIDI note on events
        // Could trigger effects, change visualizations, etc.
        print("Note On: \(note), Velocity: \(velocity), Channel: \(channel)")
    }
    
    private func handleNoteOff(note: UInt8, channel: UInt8) {
        // Handle MIDI note off events
        print("Note Off: \(note), Channel: \(channel)")
    }
    
    private func handleControlChange(controller: UInt8, value: UInt8, channel: UInt8) {
        // Handle MIDI control change events
        // Could control effect parameters, volume, etc.
        print("Control Change: Controller \(controller), Value: \(value), Channel: \(channel)")
    }
    
    deinit {
        MIDIClientDispose(midiClient)
    }
}

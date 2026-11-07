import Foundation

extension Data {
    /// Little-endian `UInt32` at `offset` from the start (0 when out of range).
    func uint32(at offset: Int) -> UInt32 {
        littleEndianValue(at: offset, size: MemoryLayout<UInt32>.size).map(UInt32.init) ?? 0
    }

    /// Little-endian `UInt64` at `offset` from the start (0 when out of range).
    func uint64(at offset: Int) -> UInt64 {
        littleEndianValue(at: offset, size: MemoryLayout<UInt64>.size) ?? 0
    }

    private func littleEndianValue(at offset: Int, size: Int) -> UInt64? {
        guard offset >= 0, offset + size <= count else { return nil }
        let bitsPerByte = 8
        return (0 ..< size).reduce(UInt64(0)) { value, index in
            value | UInt64(self[startIndex + offset + index]) << (index * bitsPerByte)
        }
    }
}

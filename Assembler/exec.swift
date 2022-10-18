//
//  exec.swift
//  Assembler
//
//  Created by charlotte on 2022-10-16.
//

import Foundation

func executeAssemblyBytes<T>(returnType: T.Type = Void.self, _ code: [UInt8]) -> T {
    let pageSize = vm_page_size
    let pageCount = Int((Double(code.count * 8) / Double(pageSize)).rounded(.up))
    print(pageCount)
    
    let pages = stride(from: 0, to: code.count, by: Int(pageSize)).map { startIndex in
        let endIndex = (startIndex.advanced(by: Int(pageSize)) > code.count) ? code.count-startIndex : Int(pageSize)
        return Array(code[startIndex ..< endIndex])
    }
    for code in pages {
        return code.withUnsafeBufferPointer { buf in
            let size = MemoryLayout.size(ofValue: code) * code.count
            if code == pages.last {
                let result = assembly(buf.baseAddress, size)
                return unsafeBitCast(result, to: T.self)
            } else {
                assembly(buf.baseAddress, size)
            }
            fatalError()
        }
    }
    fatalError()
}

func byteArray<T>(from value: T) -> [UInt8] where T: FixedWidthInteger {
    Array(withUnsafeBytes(of: value.bigEndian, Array.init).dropFirst(4))
}

@discardableResult
func asm<T>(@InstructionBuilder _ instructions: () -> [UInt8]) -> T {
    return executeAssemblyBytes(returnType: T.self, instructions())
}

@resultBuilder
struct InstructionBuilder {
    static func buildBlock(_ components: Instruction...) -> [UInt8] {
        print(components.map { $0.bytes() }.joined().map { String(format:"%02X", $0) }.joined(separator: ", 0x"))
        return Array(
            components.map { $0.bytes() }.joined()
        )
    }
}

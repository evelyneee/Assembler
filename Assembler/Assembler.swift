//
//  Assembler.swift
//  Assembler
//
//  Created by evelyn on 2022-10-16.
//

import Foundation

protocol Instruction {
        
    init(encoded: Int)
    
    func bytes() -> [UInt8]
    
}

func ror(_ x: Int, _ y: Int) -> Int {
    ((x >> y) | (x << (32 - y)) & 0xFFFFFFFF)
}

extension Instruction {
    static func encodeRegisterInt(_ base: Int, _ rd: Register, _ value: Int) -> Int {
        var base = base
        base |= (rd.w ? 0 : 1) << 31
        base |= value << 5
        base |= rd.value
        let result = reverse(base)
        return result
    }
    
    static func encodeRegRegRegCond(_ base: Int, _ rd: Register, _ rm: Register, _ rn: Register, _ cond: Int) -> Int {
        var base = base
        base |= (rd.w ? 0 : 1) << 31
        base |= rn.value << 16
        base |= cond << 12
        base |= rm.value << 5
        base |= rd.value
        let result = reverse(base)
        return result
    }
}

func reverse(_ base: Int) -> Int {
    ((base>>24)&0xff) | ((base<<8)&0xff0000) | ((base>>8)&0xff00) | ((base<<24)&0xff000000)
}

func encodeOperand(_ val: Int) -> Int {
    var oval = val;

    if !(val != val & 0xFFFFFFFF) {
        for offset in 0..<32 {
            if (ror(val, offset) <= 0xFF) {
                return ror(val, offset) | (16 - offset / 2) % 16 << 8
            }
        }
    }
    return 0
}

class ret: Instruction {
    required init(encoded: Int) {
        fatalError()
    }
    
    init() {}
    
    func bytes() -> [UInt8] {
        self.ret
    }
    
    let ret: [UInt8] = [0xc0, 0x03, 0x5f, 0xd6]
}

class movz: Instruction {
    let value: Int
    
    init(_ rd: Register, _ value: Int) {
        self.value = Self.encodeRegisterInt(Self.base, rd, value)
    }
    
    required init(encoded: Int) {
        self.value = encoded
    }
    
    func bytes() -> [UInt8] {
        byteArray(from: self.value)
    }
    
    static let base = 0b0_10_100101_00_0000000000000000_00000
}

class csel: Instruction {
    let value: Int
    
    init(_ rd: Register, _ rm: Register, _ rn: Register, _ value: Cond) {
        self.value = Self.encodeRegRegRegCond(Self.base, rd, rm, rn, value.rawValue)
    }
    
    required init(encoded: Int) {
        self.value = encoded
    }
    
    func bytes() -> [UInt8] {
        byteArray(from: self.value)
    }
    
    static let base = 0b0_0_0_11010100_00000_0000_0_0_00000_00000
}

class bytes: Instruction {
    let byteValues: [UInt8]
    
    required init(encoded: Int) {
        self.byteValues = byteArray(from: encoded)
    }
    
    init(_ bytes: UInt8...) {
        self.byteValues = bytes
    }
    
    func bytes() -> [UInt8] {
        self.byteValues
    }
}

class svc: Instruction {
    required init(encoded: Int) {
        self.value = encoded
    }
    
    func bytes() -> [UInt8] {
        byteArray(from: value)
    }
    
    let value: Int
    
    init(_ sv: Int) {
        self.value = 0x010000D4 | sv << 13
    }
}

class str: Instruction {
    required init(encoded: Int) {
        self.value = encoded
    }
    
    func bytes() -> [UInt8] {
        byteArray(from: value)
    }
    
    let value: Int
    
    init(_ rd: Register, _ dest: Register, _ offset: Int = 0) {
        let destOffset = Int((Double(dest.value) / 10).rounded(.down))
        var value = 0x000000F9 | dest.value << 29 | rd.value << 24 | offset << 20 | destOffset << 16
        if offset > 0 {
            value = value + 0xff
        }
        self.value = value
    }
}

class ldr: Instruction {
    required init(encoded: Int) {
        self.value = encoded
    }
    
    func bytes() -> [UInt8] {
        byteArray(from: value)
    }
    
    let value: Int
    
    init(_ rd: Register, _ src: Register, _ offset: Int = 0) {
        if offset > 0 {
            let srcOffset = Int((Double(src.value) / 10).rounded(.down))
            let extraOffset = Int((Double(offset) / 16).rounded(.down))
            let base = 0x000040F9 + 0xff
            let srcBits = src.value << 29
            let rdBits = rd.value << 24
            let offsetBits = (offset - (extraOffset * 16)) << 20
            self.value = base | srcBits | rdBits | offsetBits | srcOffset << 16
        } else {
            let srcOffset = Int((Double(src.value) / 10).rounded(.down))
            let base = 0x000040F9
            let srcBits = src.value << 29
            let rdBits = rd.value << 24
            self.value = base | srcBits | rdBits | srcOffset << 16
        }
    }
}

//
//  main.swift
//  Assembler
//
//  Created by charlotte on 2022-10-15.
//

import Foundation

print("Hello, World!")

let code: [UInt8] = [
    0x20, 0x00, 0x80, 0xd2, // mov x0, #1
    0x30, 0x00, 0x80, 0xd2, // mov x16, #1
    0x01, 0x10, 0x00, 0xd4, // svc #0x80
    0xc0, 0x03, 0x5f, 0xd6 // ret
]



let result: UInt64 = asm {
    movz(.x0, 0)
    movz(.x9, 1)
    str(.x9, .sp, 20)
    ldr(.x1, .sp, 20)
    add(.x1, .x1, 2)
    movz(.x2, 5)
    sub(.xzr, .x0, 0) // cmp x0, #0
    csel(.x0, .x1, .x2, .EQ)
    ret() // 3
}

print(result)


//! math operations
//!
//! Integer operations that cause values to exceed the number
//! of bits available for representation are one of the 
//! instances of undefined behavior.
//!
//! see: https://zig.run/#109_math_overflow
//! see: https://ziglang.org/documentation/0.7.1/#Undefined-Behavior 
//! see: https://ziglang.org/documentation/0.7.1/#Integer-Overflow
//!
const std = @import("std");
const expectEqual = std.testing.expectEqual;

pub fn add(a: u8, b: u8) u8 {
    return a + b;
}

pub fn sub(a: u8, b: u8) u8 {
    return a - b;
}

// Press the checkmark button on the left to execute
// `zig test main.zig` in the code playground.
test "add" {
    const expected: u8 = 8;
    expectEqual(expected, add(5, 3));
}

// This triggers integer overflow.
// test "add" {
//     const expected: u8 = 0;
//     expectEqual(expected, add(255, 1));
// }

test "sub" {
    const expected: u8 = 2;
    expectEqual(expected, sub(5, 3));
}

// This triggers integer overflow.
// test "sub" {
//     const expected: u8 = 0;
//     expectEqual(expected, sub(0, 1));
// }

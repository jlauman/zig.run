//! math overflow
//!
//! Integer operations that cause values to exceed the number
//! of bits available for representation are one of the 
//! instances of undefined behavior. Refer to the Zig documentation
//! for methods of handling undefined behavior at runtime.
//!
//! see: https://ziglang.org/documentation/0.7.1/#Undefined-Behavior 
//! see: https://ziglang.org/documentation/0.7.1/#Integer-Overflow
//! see: https://ziglang.org/documentation/0.7.1/#addWithOverflow
//! see: https://ziglang.org/documentation/0.7.1/#subWithOverflow
//!
const std = @import("std");
const expectError = std.testing.expectError;
const expectEqual = std.testing.expectEqual;

pub fn add(a: u8, b: u8) error{Overflow}!u8 {
    var result: u8 = undefined;
    if (@addWithOverflow(u8, a, b, &result)) {
        return error.Overflow;
    }
    return result;
}

pub fn sub(a: u8, b: u8) error{Overflow}!u8 {
    var result: u8 = undefined;
    if (@subWithOverflow(u8, a, b, &result)) {
        return error.Overflow;
    }
    return result;
}

test "add" {
    const expected: u8 = 8;
    expectEqual(expected, try add(5, 3));
}

test "add" {
    expectError(error.Overflow, add(255, 1));
}

test "sub" {
    const expected: u8 = 2;
    expectEqual(expected, try sub(5, 3));
}

test "sub" {
    expectError(error.Overflow, sub(3, 5));
}

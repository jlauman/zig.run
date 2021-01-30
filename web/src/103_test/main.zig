//! test
//!
//! Zig includes a built-in mechanism for writing tests to
//! ensure code execution meets expected behavior. The `test`
//! keyword is used to define a top-level block containing
//! assertions against code. Tests are frequently in the same
//! file as the functions being tested.
//!
//! The `testing.zig` file in the standard library contains
//! a set of functions prefixed with "expect" to write
//! assertions.
//!
//! The `std.buildin.is_test` constant is true when the
//! currently executing code is a test build.
//!
//! see: https://ziglang.org/documentation/0.7.1/#Zig-Test
//! see: https://github.com/ziglang/zig/blob/0.7.1/lib/std/testing.zig#L43
//!
const std = @import("std");
const print = std.debug.print;
const expect = std.testing.expect;
const expectEqual = std.testing.expectEqual;

// global variable
var everything: u8 = 42;

pub fn main() !void {
    print("std.builtin.is_test={}\n", .{std.builtin.is_test});
    print("use zig test command.", .{});
}

// Press the checkmark button on the left to execute
// `zig test main.zig` in the code playground.
test "std.builtin.is_test" {
    expect(std.builtin.is_test);
}

test "the answer" {
    expectEqual(everything, 42);
}

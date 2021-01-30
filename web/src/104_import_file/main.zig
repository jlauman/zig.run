//! @import
//!
//! An @import brings another package into the build, and
//! makes the package available to the current file as a
//! struct.
//!
//! The @import("std") and @import("builtin") are always
//! available, and relative paths are resolved in relation
//! to the file that contains the @import.
//!
//! Imports are not restricted to the top of the file.
//!
//! see: https://ziglang.org/documentation/0.7.1/#import
//! see: https://ziglang.org/documentation/0.7.1/#Functions
//!
const std = @import("std");
const print = std.debug.print;

const hello = @import("./hello.zig");

pub fn main() !void {
    const howdy = @import("./howdy.zig");
    const stdout_file = std.io.getStdOut();
    defer stdout_file.close();
    const stdout = stdout_file.writer();

    // the buffer is reused for each bprint call, and
    // strN variables are a slice into the same buffer
    var buffer: [64]u8 = undefined;
    const str1 = hello.bprint(&buffer, "world");
    try stdout.print("{}\n", .{str1});
    const str2 = howdy.bprint(&buffer, "world");
    try stdout.print("{}\n", .{str2});
    // not visible outside of the source file
    // const str3 = informal.hi(&buffer, "world");
    const str3 = informal.bprint(&buffer, "world");
    try stdout.print("{}\n", .{str3});
    // the same buffer...
    try stdout.print("str1? {}\n", .{str1});
}

const informal = @import("./hi.zig");

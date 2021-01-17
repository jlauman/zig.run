//! Here is another import.
const std = @import("std");
const print = std.debug.print;

//! This is an exported funciton.
pub fn greet(name: []const u8) void {
    print("hello, {}\n", .{name});
}

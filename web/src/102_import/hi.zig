//! an informal greeting
//!
//! see: https://ziglang.org/documentation/0.7.1/#Functions
//! see: https://github.com/ziglang/zig/blob/0.7.1/lib/std/fmt.zig#L1249
//!
const std = @import("std");

// this is a public function
pub fn bprint(buffer: []u8, name: []const u8) ![]u8 {
    return hi(buffer, name);
}

// this is a private function
fn hi(buffer: []u8, name: []const u8) ![]u8 {
    const slice = try std.fmt.bufPrint(buffer, "hi, {}!", .{name});
    return slice;
}

// this is a private function
fn hey(buffer: []u8, name: []const u8) ![]u8 {
    const slice = try std.fmt.bufPrint(buffer, "hey, {}!", .{name});
    return slice;
}

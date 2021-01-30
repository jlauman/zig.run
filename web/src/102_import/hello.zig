//! a common greeting
//!
//! see: https://github.com/ziglang/zig/blob/0.7.1/lib/std/fmt.zig#L1249 
//!
const std = @import("std");

/// This is a public function.
pub fn bprint(buffer: []u8, name: []const u8) ![]u8 {
    const slice = try std.fmt.bufPrint(buffer, "hello, {}!", .{name});
    return slice;
}

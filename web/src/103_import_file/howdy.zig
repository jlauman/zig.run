//! a cowboy greeting
//!
//! see: https://github.com/ziglang/zig/blob/0.7.1/lib/std/fmt.zig#L1249-L1253
//!
const std = @import("std");

// this is a public function
pub fn bprint(buffer: []u8, name: []const u8) ![]u8 {
    const slice = try std.fmt.bufPrint(buffer, "howdy, {}!", .{name});
    return slice;
}

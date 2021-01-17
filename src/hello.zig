const std = @import("std");
const print = std.debug.print;

pub fn main() !void {
    print("{}\n", .{"hello world!"});
    print("{}\n", .{"this is more zig."});
}

//! Source Location
//! see: https://ziglang.org/documentation/master/#src
//! for std.builtin.SourceLocation
//! see: https://github.com/ziglang/zig/blob/master/lib/std/builtin.zig
const std = @import("std");
const print = std.debug.print;
const expect = std.testing.expect;

pub fn main() !void {
    // const file_name = std.fs.path.basename(@src().file);
    // print("  file: {}\n", .{file_name});
    print("file: 101_source_locatin/main.zig\n", .{});
    _ = sourceLocation();
}

pub fn sourceLocation() u32 {
    // ...from builtin.zig
    // pub const SourceLocation = struct {
    //     file: [:0]const u8,
    //     fn_name: [:0]const u8,
    //     line: u32,
    //     column: u32,
    // };
    const src = @src();
    print("\n  {}\n", .{src});
    return src.line;
}

test "std.builtin.SourceLocation" {
    expect(sourceLocation() == 19);
}

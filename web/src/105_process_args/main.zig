//! std.process.argsAlloc
//!
//! The default command-line argument parser requires
//! an allocator and returns a slice of strings ([]u8).
//!
//! see: https://github.com/ziglang/zig/blob/0.7.1/lib/std/process.zig#L504
//!
const std = @import("std");

pub fn main() !void {
    const stdout_file = std.io.getStdOut();
    defer stdout_file.close();
    const stdout = stdout_file.writer();

    // var aa = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    // defer aa.deinit();
    // var allocator = &aa.allocator;
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    var allocator = &gpa.allocator;
    defer if (gpa.deinit()) std.os.exit(1);

    const args = try std.process.argsAlloc(allocator);
    // comment the next line to trigger memory leak detection
    defer std.process.argsFree(allocator, args);

    if (args.len > 1) {
        for (args) |arg, index| {
            try stdout.print("arg[{}]={}\n", .{ index, arg });
        }
    } else {
        try stdout.print("enter arguments into the argv field.", .{});
    }
}

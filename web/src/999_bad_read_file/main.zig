//! bad read file
//!
//! Confirm that zig user cannot read files visible to web server.
//!
const std = @import("std");
const print = std.debug.print;

pub fn main() !void {
    print("999_bad_read_file\n", .{});
    var cwd = std.fs.cwd();
    var buffer: [256]u8 = undefined;

    var file_path = try cwd.realpath(".", &buffer);
    print("cwd={}\n", .{file_path});

    // file_path = try cwd.realpath("main.zig", &buffer);
    file_path = try cwd.realpath("../../src/999_bad_read_file/main.zig", &buffer);
    print("file_path={}\n", .{file_path});

    var aa = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer aa.deinit();
    var allocator = &aa.allocator;

    var list = std.ArrayList(u8).init(allocator);
    const file = try std.fs.cwd().openFile(file_path, .{ .read = true });
    defer file.close();
    try file.reader().readAllArrayList(&list, 2 * 1024);
    print("file...\n{}\n", .{list.items});
}

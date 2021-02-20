//! bad openDir
//!
//! try to read a file from the tmp folder.
//!
const std = @import("std");
const print = std.debug.print;

pub fn main() !void {
    print("999_bad_opendir\n", .{});
    var cwd = std.fs.cwd();
    var buffer: [256]u8 = undefined;

    var tmp_path = try cwd.realpath("..", &buffer);
    print("tmp_path={}\n", .{tmp_path});

    var tmp_dir = try cwd.openDir(tmp_path, .{ .iterate = true });
    defer tmp_dir.close();
    var it = tmp_dir.iterate();
    while (try it.next()) |entry| {
        print("entry.name={}\n", .{entry.name});
    }
}

const std = @import("std");
const process = std.process;
const Allocator = std.mem.Allocator;

pub fn resolveExePath(allocator: *Allocator) ![]const u8 {
    const args = try std.process.argsAlloc(allocator);
    defer process.argsFree(allocator, args);
    // std.debug.print("args[{}]={}\n", .{0, args[0]});
    const exe_path = try std.fs.path.resolve(allocator, &[_][]const u8{args[0]});
    return exe_path;
}

pub fn resolveHomePath(allocator: *Allocator, exe_path: []const u8) ![]const u8 {
    const path = std.fs.path.dirname(exe_path) orelse return error.FileNotFound;
    return try std.fs.path.resolve(allocator, &[_][]const u8{ path, ".." });
}

pub fn resolveTmpPath(allocator: *Allocator, exe_path: []const u8) ![]const u8 {
    const path = std.fs.path.dirname(exe_path) orelse return error.FileNotFound;
    return try std.fs.path.resolve(allocator, &[_][]const u8{ path, "../tmp" });
}

pub fn resolveSrcPath(allocator: *Allocator, exe_path: []const u8) ![]const u8 {
    const path = std.fs.path.dirname(exe_path) orelse return error.FileNotFound;
    return try std.fs.path.resolve(allocator, &[_][]const u8{ path, "../src" });
}

pub fn resolveExamplePath(allocator: *Allocator, exe_path: []const u8, example_name: []const u8) ![]const u8 {
    const path = std.fs.path.dirname(exe_path) orelse return error.FileNotFound;
    return try std.fs.path.resolve(allocator, &[_][]const u8{ path, "../src", example_name });
}

pub fn readMainTitle(allocator: *Allocator, src_path: []const u8, example_name: []const u8) ![]const u8 {
    const main_zig_path = try std.fs.path.resolve(allocator, &[_][]const u8{ src_path, example_name, "main.zig" });
    defer allocator.free(main_zig_path);
    const file = try std.fs.openFileAbsolute(main_zig_path, .{ .read = true });
    defer file.close();

    var buffer: [256]u8 = undefined;
    const bytes_read = file.readAll(&buffer);
    const string = buffer[0..];
    // std.debug.print("util: string={}\n", .{string});
    var title: []u8 = undefined;
    const opt_i = std.mem.indexOf(u8, string, "\n");
    if (std.mem.startsWith(u8, string, "//! ")) {
        if (opt_i) |i| {
            const tmp = string[4..i];
            title = try allocator.alloc(u8, tmp.len);
            std.mem.copy(u8, title, tmp);
        }
    } else {
        title = try allocator.alloc(u8, example_name.len);
        std.mem.copy(u8, title, example_name);
    }
    // std.debug.print("util: title={}\n", .{title});
    return title;
}

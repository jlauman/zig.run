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

pub fn readTitleFromExample(allocator: *Allocator, src_path: []const u8, example_name: []const u8) ![]const u8 {
    const main_zig_path = try std.fs.path.resolve(allocator, &[_][]const u8{ src_path, example_name, "main.zig" });
    defer allocator.free(main_zig_path);
    const file = std.fs.openFileAbsolute(main_zig_path, .{ .read = true }) catch {
        // no main.zig file... use first zig file
        const example_path = try std.fs.path.resolve(allocator, &[_][]const u8{ src_path, example_name });
        defer allocator.free(example_path);
        var example_dir = try std.fs.cwd().openDir(example_path, .{ .iterate = true });
        defer example_dir.close();
        var file_name_opt: ?[]const u8 = null;
        var it = example_dir.iterate();
        while (try it.next()) |entry| {
            if (entry.kind == .File and std.mem.endsWith(u8, entry.name, ".zig")) {
                file_name_opt = entry.name;
                break;
            }
        }
        if (file_name_opt) |file_name| {
            // std.debug.print("util.cgi: first zig file_name={}\n", .{file_name});
            const file_zig_path = try std.fs.path.resolve(allocator, &[_][]const u8{ src_path, example_name, file_name });
            defer allocator.free(file_zig_path);
            // std.debug.print("util.cgi: first zig file_zig_path={}\n", .{file_zig_path});
            const file = try std.fs.openFileAbsolute(file_zig_path, .{ .read = true });
            defer file.close();
            return try readTitleFromFile(allocator, file, example_name);
        }
        return try readTitleFromFile(allocator, null, example_name);
    };
    defer file.close();

    return try readTitleFromFile(allocator, file, example_name);
}

pub fn readTitleFromFile(allocator: *Allocator, file_opt: ?std.fs.File, example_name: []const u8) ![]const u8 {
    // std.debug.print("util.zig: file_opt={}\n", .{file_opt});
    var title: []u8 = undefined;
    if (file_opt) |file| {
        var buffer: [256]u8 = undefined;
        const bytes_read = file.readAll(&buffer);
        const string = buffer[0..];
        // std.debug.print("util: string={}\n", .{string});
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
    } else {
        title = try allocator.alloc(u8, example_name.len);
        std.mem.copy(u8, title, example_name);
    }
    // std.debug.print("util: title={}\n", .{title});
    return title;
}

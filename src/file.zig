const std = @import("std");
const os = std.os;
const mem = std.mem;
const process = std.process;
const Allocator = std.mem.Allocator;

const ResponseEntry = struct {
    name: []const u8,
    file: []const u8,
};

const Response = struct {
    folders: []ResponseEntry,
};

pub fn main() !void {
    const stderr = std.io.getStdErr().writer();
    const stdout = std.io.getStdOut().writer();

    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    var allocator = &gpa.allocator;
    defer _ = gpa.deinit();

    const exe_path = try resolveExePath(allocator);
    defer allocator.free(exe_path);
    try stderr.print("file.cgi: exe_path={}\n", .{exe_path});

    const home_path = try resolveHomePath(allocator, exe_path);
    defer allocator.free(home_path);
    try stderr.print("file.cgi: home_path={}\n", .{home_path});

    const tmp_path = try resolveTmpPath(allocator, exe_path);
    defer allocator.free(tmp_path);
    try stderr.print("file.cgi: tmp_path={}\n", .{tmp_path});
    std.fs.cwd().access(tmp_path, .{ .read = true }) catch |err| {
        try stdout.print("Status: 400 Bad Request\n\n", .{});
        return;
    };

    const src_path = try resolveSrcPath(allocator, exe_path);
    defer allocator.free(src_path);
    try stderr.print("file.cgi: src_path={}\n", .{src_path});
    std.fs.cwd().access(src_path, .{ .read = true }) catch |err| {
        try stdout.print("Status: 400 Bad Request\n\n", .{});
        return;
    };

    var env_map = try process.getEnvMap(allocator);
    defer env_map.deinit();

    var env_it = env_map.iterator();
    // while (env_it.next()) |entry| {
    //     try stderr.print("file.cgi: key={}, value={}\n", .{ entry.key, entry.value });
    // }

    var opt_example_name: ?[]const u8 = null;
    const opt_req_uri = env_map.get("REQUEST_URI");
    try stderr.print("file.cgi: optional_request_uri={}\n", .{opt_req_uri});
    if (opt_req_uri) |request_uri| {
        const prefix = "/bin/file.cgi?example=";
        if (std.mem.startsWith(u8, request_uri, prefix)) {
            opt_example_name = request_uri[prefix.len..];
        }
    }
    try stderr.print("file.cgi: example_name={}\n", .{opt_example_name});

    if (opt_example_name) |example_name| {
        const example_path = try resolveExamplePath(allocator, exe_path, example_name);
        defer allocator.free(example_path);
        try stderr.print("file.cgi: example_path={}\n", .{example_path});
        std.fs.cwd().access(example_path, .{ .read = true }) catch |err| {
            try stdout.print("Status: 400 Bad Request\n\n", .{});
            return;
        };
        var string2 = std.ArrayList(u8).init(allocator);
        defer string2.deinit();
        var example_dir = try std.fs.cwd().openDir(example_path, .{ .iterate = true });
        defer example_dir.close();
        var it = example_dir.iterate();
        while (try it.next()) |entry| {
            if (entry.kind == .File) {
                const file_name = entry.name;
                try stderr.print("file.cgi: file_name={}\n", .{file_name});
                try string2.appendSlice("//@file_name=");
                try string2.appendSlice(file_name);
                try string2.appendSlice("\n");

                const file = try example_dir.openFile(file_name, .{ .read = true });
                defer file.close();

                var buffer: [16 * 1024]u8 = undefined;
                const bytes_read = try file.readAll(&buffer);
                try string2.appendSlice(buffer[0..bytes_read]);
            }
        }

        try stdout.print("Content-Type: text/plain\n", .{});
        try stdout.print("Content-Length: {}\n", .{string2.items.len});
        try stdout.print("\n", .{});
        try stdout.print("{}\n", .{string2.items});
    } else {
        var folders = std.ArrayList(ResponseEntry).init(allocator);
        defer folders.deinit();
        const src_dir = try std.fs.cwd().openDir(src_path, .{ .iterate = true });
        var it = src_dir.iterate();
        while (try it.next()) |entry| {
            if (entry.kind == .Directory) {
                try stderr.print("file.cgi: name={}\n", .{entry.name});
                const tmp = ResponseEntry{ .name = "example 1", .file = entry.name };
                try folders.append(tmp);
            }
        }

        const response = &Response{ .folders = folders.toOwnedSlice() };
        defer allocator.free(response.folders);
        var string2 = std.ArrayList(u8).init(allocator);
        defer string2.deinit();
        try std.json.stringify(response, .{}, string2.writer());

        // write http response
        try stdout.print("Content-Type: application/json\n", .{});
        try stdout.print("Content-Length: {}\n", .{string2.items.len});
        try stdout.print("\n", .{});
        try stdout.print("{}\n", .{string2.items});
    }
}

fn resolveExePath(allocator: *Allocator) ![]const u8 {
    const args = try std.process.argsAlloc(allocator);
    defer process.argsFree(allocator, args);
    // std.debug.print("args[{}]={}\n", .{0, args[0]});
    const exe_path = try std.fs.path.resolve(allocator, &[_][]const u8{args[0]});
    return exe_path;
}

fn resolveHomePath(allocator: *Allocator, exe_path: []const u8) ![]const u8 {
    const path = std.fs.path.dirname(exe_path) orelse return error.FileNotFound;
    return try std.fs.path.resolve(allocator, &[_][]const u8{ path, ".." });
}

fn resolveTmpPath(allocator: *Allocator, exe_path: []const u8) ![]const u8 {
    const path = std.fs.path.dirname(exe_path) orelse return error.FileNotFound;
    return try std.fs.path.resolve(allocator, &[_][]const u8{ path, "../tmp" });
}

fn resolveSrcPath(allocator: *Allocator, exe_path: []const u8) ![]const u8 {
    const path = std.fs.path.dirname(exe_path) orelse return error.FileNotFound;
    return try std.fs.path.resolve(allocator, &[_][]const u8{ path, "../doc/src" });
}

fn resolveExamplePath(allocator: *Allocator, exe_path: []const u8, example_name: []const u8) ![]const u8 {
    const path = std.fs.path.dirname(exe_path) orelse return error.FileNotFound;
    return try std.fs.path.resolve(allocator, &[_][]const u8{ path, "../doc/src", example_name });
}

fn readStdIn(buffer: []u8) !usize {
    const stdin = std.io.getStdIn().inStream();
    const count = try stdin.readAll(buffer);
    return count;
}

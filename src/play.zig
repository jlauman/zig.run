const std = @import("std");
const os = std.os;
const mem = std.mem;
const process = std.process;
const Allocator = std.mem.Allocator;
const util = @import("util.zig");

const RequestResponse = struct {
    command: []const u8,
    file_name: []const u8,
    source: []const u8,
    argv: []const u8,
    stderr: []const u8,
    stdout: []const u8,
};

pub fn main() !void {
    const stderr = std.io.getStdErr().writer();
    const stdout = std.io.getStdOut().writer();

    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    var allocator = &gpa.allocator;
    defer _ = gpa.deinit();

    const exe_path = try util.resolveExePath(allocator);
    defer allocator.free(exe_path);
    // try stderr.print("play.cgi: exe_path={}\n", .{exe_path});

    const home_path = try util.resolveHomePath(allocator, exe_path);
    defer allocator.free(home_path);
    // try stderr.print("play.cgi: home_path={}\n", .{home_path});

    const tmp_path = try util.resolveTmpPath(allocator, exe_path);
    defer allocator.free(tmp_path);
    // try stderr.print("play.cgi: tmp_path={}\n", .{tmp_path});
    std.fs.cwd().access(tmp_path, .{ .read = true }) catch |err| {
        try stdout.print("Status: 400 Bad Request\n\n", .{});
        return;
    };

    var env_map = try process.getEnvMap(allocator);
    defer env_map.deinit();

    // var env_it = env_map.iterator();
    // while (env_it.next()) |entry| {
    //     try stderr.print("play.cgi: key={}, value={}\n", .{ entry.key, entry.value });
    // }

    const buffer_size: usize = 16 * 1024;
    var buffer: [buffer_size]u8 = undefined;
    var count = try readStdIn(buffer[0..]);
    if (count == 0) return;
    // if (count > buffer_size) return error.StreamTooLong;

    var string = buffer[0..count];
    // try stderr.print("{}\n", .{string});

    // parse http request body into a Request struct
    var stream = std.json.TokenStream.init(string);
    const request = try std.json.parse(RequestResponse, &stream, .{ .allocator = allocator });
    defer std.json.parseFree(RequestResponse, request, .{ .allocator = allocator });

    var command: []const u8 = undefined;
    if (mem.eql(u8, request.command, "run")) {
        command = "run";
    } else if (mem.eql(u8, request.command, "test")) {
        command = "test";
    } else if (mem.eql(u8, request.command, "format")) {
        command = "fmt";
    } else {
        try stdout.print("Status: 400 Bad Request\n\n", .{});
        try stdout.print("\n", .{});
        try stdout.print("command={}\n", .{request.command});
        return;
    }
    try stderr.print("play.cgi: command={}\n", .{command});
    
    // use millisecond timestamp to ensure unique source file path
    var ts_buffer: [24]u8 = undefined;
    const ts = try std.fmt.bufPrint(&ts_buffer, "{}", .{std.time.milliTimestamp()});
    const ts_path = try std.fs.path.joinPosix(allocator, &[_][]const u8{ tmp_path, ts });
    defer allocator.free(ts_path);
    // try stderr.print("play.cgi: ts_path={}\n", .{ts_path});
    try std.os.mkdir(ts_path, 0o755);

    // create zig file for compile step
    // try stderr.print("{}\n", .{request.source});
    var file: ?std.fs.File = null;
    var line_it = std.mem.split(request.source, "\n");
    while (line_it.next()) |line| {
        // try stderr.print("{}\n", .{line});
        if (std.mem.startsWith(u8, line, "//@file_name=")) {
            if (file) |f| f.close();
            const idx1 = 13;
            const file_name = line[idx1..];
            // try stderr.print("play.cgi: file_name={}\n", .{file_name});
            const file_path = try std.fs.path.joinPosix(allocator, &[_][]const u8{ tmp_path, ts, file_name });
            defer allocator.free(file_path);
            try stderr.print("play.cgi: file_path={}\n", .{file_path});
            file = try std.fs.cwd().createFile(file_path, .{});
        } else if (file) |f| {
            _ = try f.write(line);
            _ = try f.write("\n");
        }
    }
    if (file) |f| f.close();

    var file_name: []const u8 = undefined;
    if (mem.eql(u8, command, "run")) {
        file_name = "main.zig";
    } else {
        file_name = request.file_name;
    }

    var argv_list = std.ArrayList([]const u8).init(allocator);
    defer argv_list.deinit();
    try argv_list.append("/usr/local/zig/zig");
    try argv_list.append(command);
    try argv_list.append(file_name);

    // try stderr.print("play.cgi: request.argv.len={}\n", .{request.argv.len});
    if (mem.eql(u8, command, "run") and request.argv.len > 0) {
        try argv_list.append("--");
        var it = std.mem.split(request.argv, " ");
        while (it.next()) |value| {
            try argv_list.append(value);
        }
    }
    // for (argv_list.items) |value, i| {
    //     try stderr.print("play.cgi: argv_list[{}]={}\n", .{ i, value });
    // }

    var exec_env_map = std.BufMap.init(allocator);
    defer exec_env_map.deinit();
    try exec_env_map.set("HOME", home_path);

    const result = try std.ChildProcess.exec(.{
        .allocator = allocator,
        .argv = argv_list.items,
        .cwd = ts_path,
        .env_map = &exec_env_map,
        .max_output_bytes = 128 * 1024,
    });
    defer {
        allocator.free(result.stdout);
        allocator.free(result.stderr);
    }

    var source_buffer: [16 * 1024]u8 = undefined;
    var source: []const u8 = undefined;
    if (mem.eql(u8, command, "fmt")) {
        const file_path = try std.fs.path.joinPosix(allocator, &[_][]const u8{ ts_path, file_name });
        defer allocator.free(file_path);
        var source_file = try std.fs.cwd().openFile(file_path, std.fs.File.OpenFlags{ .read = true });
        defer source_file.close();
        const bytes_read = try source_file.reader().read(source_buffer[0..]);
        source = source_buffer[0..bytes_read];
    } else {
        source = "";
    }

    const response = &RequestResponse{
        .command = command,
        .file_name = file_name,
        .source = source,
        .argv = "",
        .stderr = result.stderr,
        .stdout = result.stdout,
    };
    var string2 = std.ArrayList(u8).init(allocator);
    defer string2.deinit();

    try std.json.stringify(response, .{}, string2.writer());

    // write http response
    try stdout.print("Content-Type: application/json\n", .{});
    try stdout.print("Content-Length: {}\n", .{string2.items.len});
    try stdout.print("\n", .{});
    try stdout.print("{}\n", .{string2.items});
}

fn readStdIn(buffer: []u8) !usize {
    const stdin = std.io.getStdIn().inStream();
    const count = try stdin.readAll(buffer);
    return count;
}

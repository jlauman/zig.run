const std = @import("std");
const os = std.os;
const mem = std.mem;
const process = std.process;
const Allocator = std.mem.Allocator;
const util = @import("util.zig");

const ResponseEntry = struct {
    title: []const u8,
    name: []const u8,
};

const Response = struct {
    examples: []ResponseEntry,
};

pub fn main() !void {
    const stderr = std.io.getStdErr().writer();
    const stdout = std.io.getStdOut().writer();

    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    var allocator = &gpa.allocator;
    defer _ = gpa.deinit();

    const exe_path = try util.resolveExePath(allocator);
    defer allocator.free(exe_path);
    // try stderr.print("file.cgi: exe_path={}\n", .{exe_path});

    const home_path = try util.resolveHomePath(allocator, exe_path);
    defer allocator.free(home_path);
    // try stderr.print("file.cgi: home_path={}\n", .{home_path});

    const tmp_path = try util.resolveTmpPath(allocator, exe_path);
    defer allocator.free(tmp_path);
    // try stderr.print("file.cgi: tmp_path={}\n", .{tmp_path});
    std.fs.cwd().access(tmp_path, .{ .read = true }) catch |err| {
        try stdout.print("Status: 400 Bad Request\n\n", .{});
        return;
    };

    const src_path = try util.resolveSrcPath(allocator, exe_path);
    defer allocator.free(src_path);
    try stderr.print("file.cgi: src_path={}\n", .{src_path});
    std.fs.cwd().access(src_path, .{ .read = true }) catch |err| {
        try stdout.print("Status: 400 Bad Request\n\n", .{});
        return;
    };

    var env_map = try process.getEnvMap(allocator);
    defer env_map.deinit();

    // var env_it = env_map.iterator();
    // while (env_it.next()) |entry| {
    //     try stderr.print("file.cgi: key={}, value={}\n", .{ entry.key, entry.value });
    // }

    var opt_example_name: ?[]const u8 = null;
    const opt_req_uri = env_map.get("REQUEST_URI");
    try stderr.print("file.cgi: optional_request_uri={}\n", .{opt_req_uri});
    if (opt_req_uri) |request_uri| {
        const prefix = "/bin/file.cgi?name=";
        if (std.mem.startsWith(u8, request_uri, prefix)) {
            var tmp = request_uri[prefix.len..];
            if (std.mem.indexOf(u8, tmp, "&") == null) {
                opt_example_name = tmp;
            } else {
                try stdout.print("Status: 400 Bad Request\n\n", .{});
                return;
            }
        }
    }
    try stderr.print("file.cgi: example_name={}\n", .{opt_example_name});

    if (opt_example_name) |example_name| {
        const example_path = try util.resolveExamplePath(allocator, exe_path, example_name);
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
                // try stderr.print("file.cgi: file_name={}\n", .{file_name});
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
        var exampleList = std.ArrayList(ResponseEntry).init(allocator);
        defer exampleList.deinit();
        const src_dir = try std.fs.cwd().openDir(src_path, .{ .iterate = true });
        var it = src_dir.iterate();
        while (try it.next()) |entry| {
            if (entry.kind == .Directory) {
                const title = try util.readMainTitle(allocator, src_path, entry.name);
                // free after json is serialized!!!
                // try stderr.print("file.cgi: name={}\n", .{entry.name});
                // try stderr.print("file.cgi: title={}\n", .{title});
                const tmp = ResponseEntry{ .title = title, .name = entry.name };
                try exampleList.append(tmp);
            }
        }

        const examples = exampleList.toOwnedSlice();
        std.sort.sort(ResponseEntry, examples, {}, ascendingName);
        const response = &Response{ .examples = examples };
        defer allocator.free(response.examples);
        var string2 = std.ArrayList(u8).init(allocator);
        defer string2.deinit();
        try std.json.stringify(response, .{}, string2.writer());

        // must free title strings allocated in while loop
        for (response.examples) |example| {
            allocator.free(example.title);
        }

        // write http response
        try stdout.print("Content-Type: application/json\n", .{});
        try stdout.print("Content-Length: {}\n", .{string2.items.len});
        try stdout.print("\n", .{});
        try stdout.print("{}\n", .{string2.items});
    }
}

fn ascendingName(context: void, a: ResponseEntry, b: ResponseEntry) bool {
    return std.mem.lessThan(u8, a.name, b.name);
}

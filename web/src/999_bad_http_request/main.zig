//! bad http request
//!
//! Confirm that iptables drops new outbound connections.
//!
const std = @import("std");
const print = std.debug.print;

const host = "google.com";
const CRLF = "\r\n";

pub fn main() !void {
    print("HTTP GET {}...\n", .{host});
    var aa = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer aa.deinit();
    var allocator = &aa.allocator;

    var connection = try std.net.tcpConnectToHost(allocator, host, 80);
    defer connection.close();

    const request_lines = [_][]const u8{
        "GET / HTTP/1.1",
        "Host: " ++ host,
        "User-Agent: Zig/0.7.1",
        "Accept: text/html; charset=UTF-8",
        "Connection: close",
        CRLF,
    }; // extra CRLF required to end headers

    const request = try std.mem.join(allocator, CRLF, &request_lines);
    defer allocator.free(request);
    print("request...\n{}", .{request});
    _ = try connection.write(request);

    print("response...\n", .{});
    var buffer: [1024]u8 = undefined;
    while (true) {
        const byte_count = try connection.read(&buffer);
        if (byte_count == 0) break;
        print("{}", .{buffer[0..byte_count]});
    }
}

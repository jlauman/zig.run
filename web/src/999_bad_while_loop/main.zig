//! bad while loop
//!
//! try to consume cpu in a tight loop.
//!
const std = @import("std");
const print = std.debug.print;

pub fn main() !void {
    print("999_bad_while_loop\n", .{});
    var count: u64 = 0;
    while (true) {
        count += 1;
        print("count={}\n", .{count});
        std.time.sleep(100 * std.time.ns_per_ms);
    }
}

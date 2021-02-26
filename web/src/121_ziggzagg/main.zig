//! Zigg Zagg
//!
//! This example uses a while continue expression to
//! increment the `i` variable.
//!
//! see: https://ziglang.org/learn/samples/#zigg-zagg
//! see: https://ziglang.org/documentation/0.7.1/#while
//!
const std = @import("std");

pub fn main() !void {
    const stdout = std.io.getStdOut().writer();
    var i: usize = 1;
    while (i <= 16) : (i += 1) {
        if (i % 15 == 0) {
            try stdout.writeAll("ZiggZagg\n");
        } else if (i % 3 == 0) {
            try stdout.writeAll("Zigg\n");
        } else if (i % 5 == 0) {
            try stdout.writeAll("Zagg\n");
        } else {
            try stdout.print("{d}\n", .{i});
        }
    }
}

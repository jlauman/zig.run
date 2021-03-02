//! std.io.getStdOut()
//!
//! Use std.io functions to get file handles for stdout and
//! stderr.
//!
const std = @import("std");

pub fn main() !void {
    const stderr_file = std.io.getStdErr();
    defer stderr_file.close();
    const stdout_file = std.io.getStdOut();
    defer stdout_file.close();

    const stderr = stderr_file.writer();
    const stdout = stdout_file.writer();

    try stderr.print("hello, {}\n", .{"stderr"});
    try stdout.print("hello, {}\n", .{"stdout"});
}

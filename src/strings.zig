//! Strings!
//!
const std = @import("std");
const print = std.debug.print;
const expect = std.testing.expect;
const eql = std.mem.eql;
const startsWith = std.mem.startsWith;
const endsWith = std.mem.endsWith;

test "string concat at comptime" {
    const str1 = "one";
    const str2: []const u8 = "two";
    const str3 = str1 ++ " " ++ str2;
    print(" str3={} ", .{str3});
    expect(eql(u8, str3, "one two"));
}

test "string eql" {
    const str = "string";
    expect(eql(u8, str, "string"));
}

test "string startsWith" {
    const str = "string";
    expect(startsWith(u8, str, "stri"));
}

test "string endsWith" {
    const str = "string";
    expect(endsWith(u8, str, "ing"));
}

//! types
//!
//! see: https://ziglang.org/documentation/0.7.1/#Primitive-Types
//! see: https://ziglang.org/documentation/0.7.1/#String-Literals-and-Character-Literals
//! see: https://ziglang.org/documentation/0.7.1/#TypeOf
//! see: https://ziglang.org/documentation/0.7.1/#typeName
//!
const std = @import("std");
const print = std.debug.print;
const expect = std.testing.expect;
const eql = std.mem.eql;

// global variables
var x: i32 = 42;
var b: bool = true;
var s: []const u8 = "hello";

test "primitive type i32" {
    expect(x == 42);
    expect(@TypeOf(x) == i32);
    expect(eql(u8, @typeName(@TypeOf(x)), "i32"));
    print(" @TypeOf x is {} ", .{@typeName(@TypeOf(x))});
}

test "primitive type bool" {
    expect(b == true);
    expect(@TypeOf(b) == bool);
    expect(eql(u8, @typeName(@TypeOf(b)), "bool"));
    print(" @TypeOf b is {} ", .{@typeName(@TypeOf(b))});
}

test "string literal type []const u8" {
    expect(eql(u8, s, "hello"));
    expect(@TypeOf(s) == []const u8);
    expect(eql(u8, @typeName(@TypeOf(s)), "[]const u8"));
    print(" @TypeOf s is {} ", .{@typeName(@TypeOf(s))});
}

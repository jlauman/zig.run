//! strings
//!
//! see: https://ziglang.org/documentation/0.7.1/#String-Literals-and-Character-Literals
//! see: https://ziglang.org/documentation/0.7.1/std/#std;mem.eql
//! see: https://ziglang.org/documentation/0.7.1/std/#std;mem.startsWith
//! see: https://ziglang.org/documentation/0.7.1/std/#std;mem.endsWith
//! see: https://ziglang.org/documentation/0.7.1/std/#std;unicode.Utf8View
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

test "multiline string" {
    const str =
        \\line one
        \\line two
        \\line three
    ; // end
    expect(endsWith(u8, str, "two\nline three"));
}

// joining requires an allocator to create a new string.
test "join strings" {
    var buffer: [64]u8 = undefined;
    var fba = std.heap.FixedBufferAllocator.init(&buffer); // or buffer[0..]
    var allocator = &fba.allocator;
    const str1 = try std.mem.join(allocator, ", ", &[_][]const u8{ "jill", "jack", "jane", "john" });
    defer allocator.free(str1);
    const str2 = try std.mem.join(allocator, "... ", &[_][]const u8{ "four", "three", "two", "one" });
    defer allocator.free(str2);
    expect(eql(u8, str1, "jill, jack, jane, john"));
    expect(eql(u8, str2, "four... three... two... one"));
}

test "iterating utf8 runes" {
    const str1: []const u8 = "こんにちは!";
    print(" str1={} ", .{str1});
    const view = try std.unicode.Utf8View.init(str1);
    var itr = view.iterator();
    var idx: u8 = 0;
    while (itr.nextCodepointSlice()) |rune| : (idx += 1) {
        if (idx == 0) {
            expect(eql(u8, rune, "こ"));
        }
        if (idx == 1) {
            expect(eql(u8, rune, "ん"));
        }
        if (idx == 4) {
            expect(eql(u8, rune, "は"));
        }
        if (idx == 5) {
            expect(eql(u8, rune, "!"));
        }
    }
}

const std = @import("std");
const Allocator = std.mem.Allocator;
const expectEqualSlices = std.testing.expectEqualSlices;

const alphabet: []const u8 = "ABCDEFGHIJKLMNOPQRSTUVWXYZABCDEFGHIJKLMNOPQRSTUVWXYZ";

pub fn rot13(allocator: *Allocator, string: []const u8) ![]const u8 {
    const encoded = try allocator.alloc(u8, string.len);
    for (string) |value, i| {
        for (alphabet) |letter, j| {
            if (value == letter) {
                encoded[i] = alphabet[j + 13];
                break;
            }
        }
    }
    return encoded[0..];
}

test "rot13 HELLO" {
    var allocator = std.testing.allocator;

    const string = "HELLO"; // string literal is 0 terminated!
    const actual1 = try rot13(allocator, string);
    defer allocator.free(actual1);

    expectEqualSlices(u8, "URYYB", actual1);
    // std.debug.print("string={}\n", .{string});
    // std.debug.print("acutal={}\n", .{actual});

}

test "rot13 URYYB" {
    var buffer: [128]u8 = undefined;
    var fba = std.heap.FixedBufferAllocator.init(&buffer); // or buffer[0..]
    var allocator = &fba.allocator;

    const actual2 = try rot13(allocator, "URYYB");
    defer allocator.free(actual2);

    expectEqualSlices(u8, "HELLO", actual2);
}
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
    var buffer: [64]u8 = undefined;
    var fba = std.heap.FixedBufferAllocator.init(&buffer); // or buffer[0..]
    var allocator = &fba.allocator;

    const hello = "HELLO"; // string literal is 0 terminated!
    const string = try allocator.alloc(u8, hello.len);
    std.mem.copy(u8, string, hello); 
    defer allocator.free(string);

    const actual = try rot13(allocator, string);
    defer allocator.free(actual);
    // std.debug.print("string={}\n", .{string});
    // std.debug.print("acutal={}\n", .{actual});
    expectEqualSlices(u8, actual, "URYYB");
}

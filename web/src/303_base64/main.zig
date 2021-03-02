//! base64
//!
//! The base64 encoder/decoder uses a length calculation
//! function to create a slice of the correct size for the
//! encoded/decoded result.
//!
//! see: https://github.com/ziglang/zig/blob/0.7.1/lib/std/base64.zig#L363
//!
const std = @import("std");
const print = std.debug.print;
const eql = std.mem.eql;

const message = "this is a message.";

pub fn main() !void {
    // print("base64: encode an decode\n", .{});
    const encoder = std.base64.standard_encoder;
    const decoder = std.base64.standard_decoder;
    // some buffers...
    var buffer1: [512]u8 = undefined;
    var buffer2: [512]u8 = undefined;
    // encode message
    // print("base64: message.len={}\n", .{message.len});
    const encoded = buffer1[0..std.base64.Base64Encoder.calcSize(message.len)];
    encoder.encode(encoded, message);
    print("base64: encoded={}\n", .{encoded});
    // decode message
    var decoded = buffer2[0..try decoder.calcSize(encoded)];
    try decoder.decode(decoded, encoded);
    print("base64: decoded={}\n", .{decoded});
}

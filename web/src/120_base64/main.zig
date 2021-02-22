//! base64
//!
//! see:
//!
const std = @import("std");
const print = std.debug.print;
const eql = std.mem.eql;

const message1 = "this is a message.";

pub fn main() !void {
    print("base64: encode an decode\n", .{});
    const encoder = std.base64.standard_encoder;
    const decoder = std.base64.standard_decoder;
    // some buffers...
    var buffer1: [512]u8 = undefined;
    var buffer2: [512]u8 = undefined;
    // encode message
    // print("base64: message1.len={}\n", .{message1.len});
    const encoded = buffer1[0..std.base64.Base64Encoder.calcSize(message1.len)];
    encoder.encode(encoded, message1);
    print("base64: encoded={}\n", .{encoded});
    // decode message
    var decoded = buffer2[0..try decoder.calcSize(encoded)];
    try decoder.decode(decoded, encoded);
    print("base64: decoded={}\n", .{decoded});
}

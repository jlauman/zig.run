//! @import
//!
//! This example show the use of the standard library import.
//! Note how "@import" may occur anywhere.
//!
const std = @import("std");
const print = std.debug.print;
/// importing another file...
const Greeter = @import("./greeter.zig");

pub fn main() !void {    
    print("{}\n", .{"hello world!"});
    Greeter.greet("jack");
}

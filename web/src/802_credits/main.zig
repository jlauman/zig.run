//! Credits
//!
//! zig.run is made with...	
//!
//! codemirror	  https://codemirror.net/
//!
//! feathericons  https://feathericons.com/
//!
//! tailwindcss	  https://tailwindcss.com/
//!
//! zig logos	  https://github.com/ziglang/logo
//!
//! github        https://github.com/jlauman/zig.run
//!
const std = @import("std");

pub fn main() !void {
    std.debug.print("{} zig.{}!\n", .{"run", "run"});
}

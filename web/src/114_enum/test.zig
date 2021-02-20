//! enum
//!
//! see: https://ziglang.org/documentation/0.7.1/#enum
//!
const std = @import("std");
const print = std.debug.print;
const eql = std.mem.eql;
const expect = std.testing.expect;

test "plant_3" {
    const plant_3 = @import("./plant_3.zig");
    const tomato = "tomato";
    var p3 = plant_3.Plant.init(tomato);
    p3.setType(plant_3.Kind.fruit);
    print("\n  p3={}", .{p3});
    print("\n  p3.kind={}", .{p3.kind});
    print("\n", .{});
    expect(eql(u8, "tomato", p3.name));
    expect(p3.isEdible() == true);
    expect(p3.isFruit() == true);
}

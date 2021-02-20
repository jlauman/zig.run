//! struct
//!
//! see: https://ziglang.org/documentation/0.7.1/#struct
//! see: https://ziglang.org/documentation/0.7.1/#Default-Field-Values
//!
const std = @import("std");
const print = std.debug.print;
const eql = std.mem.eql;
const expect = std.testing.expect;

test "anonymous struct" {
    const st1 = .{ .a = true, .b = "two", .c = 3 };
    print("\n  @TypeOf(st1) is {}", .{@typeName(@TypeOf(st1))});
    print("\n", .{});
    expect(eql(u8, st1.b, "two"));
}

test "plant_1" {
    const plant_1 = @import("./plant_1.zig");
    // note that fields are not in the order declared in the struct
    const p1 = plant_1.Plant{
        .name = "tomato",
        .is_edible = true,
        .is_fruit = true,
        .is_vegetable = false,
        .is_legume = false,
        .is_fungi = false,
    };
    print("\n  p1={}", .{p1});
    print("\n", .{});
    expect(eql(u8, "tomato", p1.name));
    expect(p1.is_fruit == true);
}

test "plant_2" {
    const plant_2 = @import("./plant_2.zig");
    const tomato = "tomato";
    var p2 = plant_2.Plant.init(tomato);
    p2.setIsFruit();
    print("\n  p2={}", .{p2});
    // print("\n  p2.is_fruit={}", .{p2.is_fruit});
    // print("\n  @TypeOf(tomato) is {}", .{@typeName(@TypeOf(tomato))});
    // print("\n  @TypeOf(p2.name) is {}", .{@typeName(@TypeOf(p2.name))});
    // print("\n  @TypeOf(p2.name[0..]) is {}", .{@typeName(@TypeOf(p2.name[0..]))});
    print("\n", .{});
    expect(eql(u8, "tomato", p2.name));
    expect(p2.isEdible());
    expect(p2.isFruit());
}

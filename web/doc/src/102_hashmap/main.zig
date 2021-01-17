//! AutoHashMap
//! see: https://ziglang.org/documentation/master/std/#std;hash_map
const std = @import("std");
const print = std.debug.print;
const expect = std.testing.expect;
const eql = std.mem.eql;


const Starship = struct {
    name: []const u8,
    number: u32,
    captain: []const u8 = "?",
};

pub fn main() !void {
    const file_name = std.fs.path.basename(@src().file);
    print("\n  file: {}\n", .{file_name});
    
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    var allocator = &gpa.allocator;
    defer if (gpa.deinit()) std.os.exit(1);

    var map = std.AutoHashMap(u32, Starship).init(allocator);
    defer map.deinit();

    try map.put(1701, Starship{
        .name = "Enterprise",
        .number = 1701,
    });

    try map.put(24383, Starship{
        .name = "Yamato",
        .number = 24383,
    });

    try map.put(1022, Starship{
        .name = "Kobayashi Maru",
        .number = 1022,
    });

    print("map.count()={}\n", .{map.count()});
    expect(map.count() == 3);

    var it = map.iterator();
    while (it.next()) |entry| {
        print("key={}, value={}\n", .{ entry.key, entry.value });
    }    
}

test "AutoHashMap" {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    var allocator = &gpa.allocator;
    defer if (gpa.deinit()) std.os.exit(1);

    var map = std.AutoHashMap(u32, Starship).init(allocator);
    defer map.deinit();

    try map.put(1701, Starship{
        .name = "Enterprise",
        .number = 1701,
    });

    try map.put(24383, Starship{
        .name = "Yamato",
        .number = 24383,
    });

    try map.put(1022, Starship{
        .name = "Kobayashi Maru",
        .number = 1022,
    });

    print("map.count()={}\n", .{map.count()});
    expect(map.count() == 3);

    var it = map.iterator();
    while (it.next()) |entry| {
        print("key={}, value={}\n", .{ entry.key, entry.value });
    }
}

test "StringHashMap" {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    var allocator = &gpa.allocator;
    defer if (gpa.deinit()) std.os.exit(1);

    var map = std.StringHashMap(Starship).init(allocator);
    defer map.deinit();

    try map.put("NX-01", Starship{
        .name = "Enterprise",
        .number = 1,
        .captain = "Archer",
    });

    try map.put("NCC-1701", Starship{
        .name = "Enterprise",
        .number = 1701,
        .captain = "Kirk",
    });

    try map.put("NCC-1701-A", Starship{
        .name = "Enterprise",
        .number = 1701,
        .captain = "Kirk",
    });

    try map.put("NCC-1701-B", Starship{
        .name = "Enterprise",
        .number = 1701,
        .captain = "Harriman",
    });

    try map.put("NCC-1701-C", Starship{
        .name = "Enterprise",
        .number = 1701,
        .captain = "Garret",
    });

    try map.put("NCC-1701-D", Starship{
        .name = "Enterprise",
        .number = 1701,
        .captain = "Picard",
    });

    print("map.count()={}\n", .{map.count()});
    expect(map.count() == 6);

    var it = map.iterator();
    while (it.next()) |entry| {
        print("key={}, value={}\n", .{ entry.key, entry.value });
    }

    const old = try map.fetchPut("NCC-1701-D", Starship{
        .name = "Enterprise",
        .number = 1701,
        .captain = "Riker",
    });

    expect(eql(u8, old.?.value.captain, "Picard"));
}


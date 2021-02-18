//! array
//!
//! An array is a contiguous sequence of values with a type and length
//! known at compile time. A sentinal-terminated array has a type known
//! at compile time and a length known at runtime. A string literal is 
//! a constant pointer to an array of byte (u8) values.
//!
//! see: https://ziglang.org/documentation/0.7.1/#Arrays
//! see: https://ziglang.org/documentation/0.7.1/#Anonymous-List-Literals
//! see: https://ziglang.org/documentation/0.7.1/#Multidimensional-Arrays
//!
const std = @import("std");
const print = std.debug.print;
const eql = std.mem.eql;
const expect = std.testing.expect;

fn print_array(prefix: []const u8, array: []const u8) void {
    print("{}{}{}", .{ prefix, @typeName(@TypeOf(array)), "{" });
    for (array) |n, i| {
        if (i < array.len - 1) {
            print(" {},", .{n});
        } else {
            print(" {} {}", .{ n, "}" });
        }
    }
}

test "array initialized to zero" {
    const five_zeros = [_]u16{0} ** 5;
    print("\n  five_zeros.len={}", .{five_zeros.len});
    print("\n  five_zeros[4]=={}", .{five_zeros[4]});
    print("\n", .{});
    expect(five_zeros.len == 5);
    for (five_zeros) |n, i| {
        // print("ten_zeros[{}]={}\n", .{i, n});
        expect(n == 0);
    }
}

// anonymous list literals are passed as arguments for `print` which
// accepts an `anytype` and performs comptime/runtime logic.
test "anonymous list literal" {
    const list = .{ 1, 2, 3 };
    print("\n  @TypeOf(list) is {}", .{@typeName(@TypeOf(list))});
    print("\n", .{});
    expect(list[2] == 3);
}

test "a string literal is a pointer to an array literal" {
    const a1 = "hello";
    const a2 = [_]u8{ 'h', 'e', 'l', 'l', 'o' };
    print("\n  @TypeOf(a1) is {}", .{@typeName(@TypeOf(a1))});
    print("\n  @TypeOf(a2) is {}", .{@typeName(@TypeOf(a2))});
    print("\n  @TypeOf(&a2) is {}", .{@typeName(@TypeOf(&a2))});
    print("\n", .{});
    expect(eql(u8, a1, &a2));
}

test "null terminated array" {
    const a3 = [_:0]u8{ 1, 2, 3, 4, 5 };
    print("\n  @TypeOf(a3) is {}", .{@typeName(@TypeOf(a3))});
    print_array("\n  a=", &a3);
    print("\n", .{});
    expect(@TypeOf(a3) == [5:0]u8);
    expect(a3.len == 5);
    expect(a3[5] == 0); // the null
}

test "a string is a null terminated array" {
    const a4 = [_:0]u8{ 104, 101, 108, 108, 111 };
    print("\n  @TypeOf(a4) is {}", .{@typeName(@TypeOf(a4))});
    print_array("\n  a4=", &a4);
    print("\n  a4={}", .{a4});
    print("\n", .{});
    expect(@TypeOf(a4) == [5:0]u8);
    expect(a4.len == 5);
    expect(a4[5] == 0); // the null
}

test "multidimentional array" {
    // legend...
    // # == wall
    // . == floor
    // @ == player
    const room = [5][5]u8{
        [_]u8{ '#', '#', '#', '#', '#' },
        [_]u8{ '#', '.', '.', '.', '#' },
        [_]u8{ '#', '.', '.', '.', '#' },
        [_]u8{ '#', '.', '@', '.', '#' },
        [_]u8{ '#', '#', '#', '#', '#' },
    };

    expect(room[3][2] == '@');

    for (room) |row, row_i| {
        for (row) |cell, col_i| {
            if (row_i == 0 or row_i == 4) {
                expect(cell == '#');
            } else if (col_i == 0 or col_i == 4) {
                expect(cell == '#');
            } else if (row_i == 3 and col_i == 2) {
                expect(cell == '@');
            } else {
                expect(cell == '.');
            }
        }
    }
}

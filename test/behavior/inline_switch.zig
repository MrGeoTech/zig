const std = @import("std");
const expect = std.testing.expect;
const builtin = @import("builtin");

test "inline scalar prongs" {
    if (builtin.zig_backend == .stage2_aarch64) return error.SkipZigTest; // TODO

    var x: usize = 0;
    switch (x) {
        10 => |*item| try expect(@TypeOf(item) == *usize),
        inline 11 => |*item| {
            try expect(@TypeOf(item) == *const usize);
            try expect(item.* == 11);
        },
        else => {},
    }
}

test "inline prong ranges" {
    if (builtin.zig_backend == .stage2_aarch64) return error.SkipZigTest; // TODO

    var x: usize = 0;
    switch (x) {
        inline 0...20, 24 => |item| {
            if (item > 25) @compileError("bad");
        },
        else => {},
    }
}

const E = enum { a, b, c, d };
test "inline switch enums" {
    if (builtin.zig_backend == .stage2_aarch64) return error.SkipZigTest; // TODO

    var x: E = .a;
    switch (x) {
        inline .a, .b => |aorb| if (aorb != .a and aorb != .b) @compileError("bad"),
        inline .c, .d => |cord| if (cord != .c and cord != .d) @compileError("bad"),
    }
}

const U = union(E) { a: void, b: u2, c: u3, d: u4 };
test "inline switch unions" {
    if (builtin.zig_backend == .stage2_aarch64) return error.SkipZigTest; // TODO
    if (builtin.zig_backend == .stage2_arm) return error.SkipZigTest; // TODO
    if (builtin.zig_backend == .stage2_x86_64) return error.SkipZigTest; // TODO

    var x: U = .a;
    switch (x) {
        inline .a, .b => |aorb, tag| {
            if (tag == .a) {
                try expect(@TypeOf(aorb) == void);
            } else {
                try expect(tag == .b);
                try expect(@TypeOf(aorb) == u2);
            }
        },
        inline .c, .d => |cord, tag| {
            if (tag == .c) {
                try expect(@TypeOf(cord) == u3);
            } else {
                try expect(tag == .d);
                try expect(@TypeOf(cord) == u4);
            }
        },
    }
}

test "inline else bool" {
    if (builtin.zig_backend == .stage2_aarch64) return error.SkipZigTest; // TODO

    var a = true;
    switch (a) {
        true => {},
        inline else => |val| if (val != false) @compileError("bad"),
    }
}

test "inline else error" {
    if (builtin.zig_backend == .stage2_aarch64) return error.SkipZigTest; // TODO

    const Err = error{ a, b, c };
    var a = Err.a;
    switch (a) {
        error.a => {},
        inline else => |val| comptime if (val == error.a) @compileError("bad"),
    }
}

test "inline else enum" {
    if (builtin.zig_backend == .stage2_aarch64) return error.SkipZigTest; // TODO
    if (builtin.zig_backend == .stage2_x86_64) return error.SkipZigTest; // TODO

    const E2 = enum(u8) { a = 2, b = 3, c = 4, d = 5 };
    var a: E2 = .a;
    switch (a) {
        .a, .b => {},
        inline else => |val| comptime if (@enumToInt(val) < 4) @compileError("bad"),
    }
}

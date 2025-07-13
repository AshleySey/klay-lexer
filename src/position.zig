const std = @import("std");
pub const Position = struct {
    x: usize,
    y: usize,
    global: usize,
    const Self = @This();
    pub fn new(x: usize, y: usize, global: usize) Self {
        Self{ .x = x, .y = y, .global = global };
    }
    pub fn toString(self: Self, allocator: std.mem.Allocator) ![]u8 {
        return try std.fmt.allocPrint(allocator, "{}:{} (row,column), at {} (global)", .{ self.y, self.x, self.global });
    }
};

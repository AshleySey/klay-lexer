const Position = @import("position.zig").Position;
const std = @import("std");
pub const LineError = error{ EndOfCode, Internal };
pub const Line = struct {
    chars: []const u8,
    position: Position,
    allocator: std.mem.Allocator,
    const Self = @This();
    pub fn init(stream: anytype, pos: Position, allocator: std.mem.Allocator) LineError!Self {
        const text = stream.readUntilDelimiterOrEofAlloc(allocator, '\n', 1024) catch {
            return LineError.Internal;
        };
        if (text != null) {
            return Self{ .chars = text.?, .position = pos, .allocator = allocator };
        } else {
            return LineError.EndOfCode;
        }
    }
    pub fn is_eof(self: Self) bool {
        if (self.position.x >= self.chars.len) return true else return false;
    }
    pub fn next(self: *Self) ?u21 {
        if (self.is_eof()) return null;
        switch (self.chars[self.position.x]) {
            else => |d| {
                self.position.x += 1;
                self.position.global += 1;
                return d;
            },
        }
    }
    pub fn toString(self: Self) ![]u8 {
        //if (!std.unicode.utf8ValidateSlice(self.chars)) {
        //    std.debug.print("chars no es UTF-8 válido\n", .{});
        // } TODO: support unicode
        const lol = try self.position.toString(self.allocator);
        defer self.allocator.free(lol);
        return try std.fmt.allocPrint(self.allocator, "{s}:{s}", .{ self.chars, lol });
    }
    pub fn deinit(self: Self) void {
        self.allocator.free(self.chars);
    }
};

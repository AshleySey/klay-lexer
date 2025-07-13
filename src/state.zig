const std = @import("std");
const Tokenize = @import("error.zig").Tokenize;
const Line = @import("line.zig").Line;
const Error = @import("error.zig").Error;
pub const State = struct {
    const Self = @This();
    actual: ?Tokenize,
    line: Line,
    pub fn init(actual: ?Tokenize, line: Line) Self {
        return Self{ .actual = actual, .line = line };
    }
    pub fn isError(self: Self) bool {
        if (self.actual == null) return false;
        switch (self.actual.?) {
            .Token => {
                return false;
            },
            .Error => {
                return true;
            },
        }
    }
};

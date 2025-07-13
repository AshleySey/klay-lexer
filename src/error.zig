const std = @import("std");
const Line = @import("line.zig").Line;
const Token = @import("tokens.zig").Token;
pub const ErrorHelper = struct {
    solution: ?[]u8 = null,
    why: ?[]u8 = null,
    note: ?[]u8 = null,
    warning: ?[]u8 = null,
    const Self = @This();
    pub fn toString(self: Self, allocator: std.mem.Allocator) ![]u8 {
        return try std.fmt.allocPrint(allocator, "{?s} {?s} {?s} {?s}", .{ self.why, self.solution, self.warning, self.note });
    }
};
pub const Error = struct {
    const Self = @This();
    name: []const u8,
    errors: std.ArrayList(Error),
    father: ?*Error,
    line: Line,
    allocator: std.mem.Allocator,
    helper: ErrorHelper,
    pub fn init(
        name: []const u8,
        father: ?*Error,
        line: Line,
        helper: ErrorHelper,
        allocator: std.mem.Allocator,
    ) Self {
        return Self{
            .name = name,
            .line = line,
            .allocator = allocator,
            .father = father,
            .errors = std.ArrayList(Error).init(allocator),
            .helper = helper,
        };
    }
    pub fn deinit(self: Self) void {
        for (self.errors.items) |err| {
            err.deinit();
        }
        self.errors.deinit();
        self.line.deinit();
        self.allocator.free(self.name);
    }
    pub fn pushChildrenError(self: *Self, child: Error) !void {
        try self.errors.append(child);
    }
    pub fn toString(self: Self) ![]u8 {
        var childrens = std.ArrayList([]u8).init(self.allocator);
        for (self.errors.items) |value| {
            try childrens.append(try value.toString());
            try childrens.append(@constCast("\n"));
        }
        const g = try self.line.toString();
        const g6 = try self.helper.toString(self.allocator);
        const g3 = std.fmt.allocPrint(self.allocator, "Error: {s} In:{s}\n{s} {s}", .{ self.name, g, childrens.items, g6 });
        self.allocator.free(g6);
        self.allocator.free(g);
        return g3;
    }
};

pub const Tokenize = union(enum) {
    Token: Token,
    Error: Error,
    const Self = @This();
    pub fn deinit(self: Self) void {
        switch (self) {
            .Token => {},
            .Error => |e| {
                e.deinit();
            },
        }
    }
};
pub const TokenizeArrayList = union(enum) {
    Tokens: std.ArrayList(Token),
    Errors: std.ArrayList(Error),
    const Self = @This();
    pub fn deinit(self: Self) void {
        switch (self) {
            .Tokens => |t| {
                for (t.items) |_| {
                    //value.deinit(); TODO: implement deinit in Token
                }
                t.deinit();
            },
            .Errors => |e| {
                for (e.items) |value| {
                    value.deinit();
                }
                e.deinit();
            },
        }
    }
};
pub fn InvalidCharacterError(
    ch: u21,
    father: ?*Error,
    line: Line,
    helper: ErrorHelper,
    allocator: std.mem.Allocator,
) Error {
    const g = std.fmt.allocPrint(allocator, "Invalid char: {u}", .{ch}) catch {
        @panic("Invalid Char !!!");
    };
    const li = allocator.dupe(u8, line.chars) catch {
        @panic("wtf, you code bugged this lexer");
    };
    return Error.init(g, father, .{ .allocator = allocator, .chars = li, .position = line.position }, helper, allocator);
}

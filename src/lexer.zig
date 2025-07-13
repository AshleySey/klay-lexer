const std = @import("std");
const Token = @import("tokens.zig").Token;
const lines = @import("line.zig");
const Line = lines.Line;
const errors = @import("error.zig");
const Error = errors.Error;
const ErrorHelper = errors.ErrorHelper;
pub const Tokenize = errors.Tokenize;
pub const utils = @import("utils.zig");
const State = @import("state.zig").State;
const ErrorLine = lines.LineError;
const TokenizeArrayList = errors.TokenizeArrayList;
pub fn Lexer() type {
    return struct {
        const Self = @This();
        allocator: std.mem.Allocator,
        reader: *std.io.StreamSource.Reader,
        state: *State,

        pub fn init(reader: *std.io.StreamSource.Reader, allocator: std.mem.Allocator) !Self {
            const line = try Line.init(reader, .{ .x = 0, .y = 0, .global = 0 }, allocator);

            const state = try allocator.create(State); // ← almacena en heap
            state.* = .{
                .actual = null,
                .line = line,
            };

            return Self{
                .allocator = allocator,
                .reader = reader,
                .state = state,
            };
        }
        pub fn next(self: *Self) !Tokenize {
            return self.genTokenOfLine(self.state);
        }
        pub fn deinit(self: Self) void {
            self.allocator.destroy(self.state);
        }
        fn genTokenOfLine(self: *Self, state: *State) !Tokenize {
            const g = state.line.next();
            if (g == null) {
                state.line.deinit();
                self.state.line = Line.init(self.reader, .{ .x = 0, .y = state.line.position.y + 1, .global = state.line.position.global + 1 }, self.allocator) catch |err| {
                    switch (err) {
                        ErrorLine.EndOfCode => {
                            self.state.actual = .{ .Token = .EndOfCode };
                            return .{ .Token = .EndOfCode };
                        },
                        ErrorLine.Internal => {
                            return err;
                            //@panic("internal error.You code is bad");
                        },
                    }
                };
                return .{ .Token = .EndOfLine };
            }
            switch (g.?) {
                '+' => {
                    return .{ .Token = .{ .Symbol = .{ .Math = .@"+" } } };
                },
                '-' => {
                    return .{ .Token = .{ .Symbol = .{ .Math = .@"-" } } };
                },
                '*' => {
                    return .{ .Token = .{ .Symbol = .{ .Math = .@"*" } } };
                },
                '/' => {
                    return .{ .Token = .{ .Symbol = .{ .Math = .@"/" } } };
                },

                else => |c| {
                    if (state.actual != null) {
                        switch (state.actual.?) {
                            .Token => {},
                            .Error => |e| {
                                return .{ .Error = errors.InvalidCharacterError(c, @constCast(&e), state.line, .{}, self.allocator) };
                            },
                        }
                    }
                    return .{ .Error = errors.InvalidCharacterError(c, null, state.line, .{}, self.allocator) };
                },
            }
        }
    };
}

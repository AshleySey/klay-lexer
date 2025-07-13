const Token = @import("tokens.zig").Token;
const std = @import("std");
const TokenizeArrayList = @import("error.zig").TokenizeArrayList;
pub fn printAllTokens(toks: std.ArrayList(Token)) void {
    for (toks.items, 0..) |value, i| {
        std.debug.print("Token: Index({}) {any}\n", .{ i, value });
    }
}
pub fn printTokenizeList(tokenize: TokenizeArrayList) !void {
    switch (tokenize) {
        .Tokens => |tokens| {
            for (tokens.items, 0..) |value, i| {
                std.debug.print("Token: Index({}) {any}\n", .{ i, value });
            }
            tokens.deinit();
        },
        .Errors => |errors| {
            for (errors.items, 0..) |value, i| {
                const h = try value.toString();
                std.debug.print("Error: Index({}) {s}\n", .{ i, h });
                errors.allocator.free(h);
                value.deinit();
            }
            errors.deinit();
        },
    }
}

const std = @import("std");
const lexer = @import("klay_lexer");
pub fn main() !void {
    const file = try std.fs.cwd().openFile("testg.kl", .{});
    var stream = std.io.StreamSource{ .file = file };
    var reader = stream.reader();
    var lex = try lexer.Lexer().init(&reader, std.heap.page_allocator);
    defer lex.deinit();
    while (true) {
        switch (try lex.next()) {
            .Token => |token| {
                switch (token) {
                    .EndOfCode => {
                        break;
                    },
                    else => {
                        //std.log.info("Token: {any}\n", .{token});
                    },
                }
            },
            .Error => {
                // std.log.err("Error: {any}\n", .{err});
            },
        }
    }
}

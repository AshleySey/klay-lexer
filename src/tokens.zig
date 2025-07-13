const Error = @import("error.zig").Error;
pub const MathOp = union(enum) {
    @"+",
    @"-",
    @"*",
    @"/",
};
pub const Symbol = union(enum) { Math: MathOp };
pub const Float = union(enum) { @"64": f64, @"32": f32 };
pub const Integer = union(enum) { Unsigned: union(enum) { @"64": u64, @"32": u32 }, Signed: union(enum) { @"64": i64, @"32": i32 } };
pub const Number = union(enum) { Float: Float, Integer: Integer };
pub const ReservedWord = union(enum) { @"if", elif, @"else" };
pub const Identify = union(enum) {
    Ident: []const u8,
    ReservedWord: ReservedWord,
};
pub const Token = union(enum) { Symbol: Symbol, Number: Number, Identify: Identify, EndOfCode, EndOfLine };


const std = @import("std");
const print = std.debug.print;

const Bert = @import("zig_erl_bert/bert.zig").Bert;
const format_bert = @import("zig_erl_bert/bert.zig").format_bert;

//const Bert_Get_Error = @import("zig_erl_bert/bert.zig").Bert_Get_Error;
const get_atom_as_str = @import("zig_erl_bert/bert.zig").get_atom_as_str;
const get_binary_as_str = @import("zig_erl_bert/bert.zig").get_binary_as_str;
const get_list = @import("zig_erl_bert/bert.zig").get_list;
const get_tuple = @import("zig_erl_bert/bert.zig").get_tuple;
const get_tuple_elem = @import("zig_erl_bert/bert.zig").get_tuple_elem;

const get_int_as_u8 = @import("zig_erl_bert/bert.zig").get_int_as_u8;
//const get_int_as_u16 = @import("zig_erl_bert/bert.zig").get_int_as_u16;
//const get_int_as_u32 = @import("zig_erl_bert/bert.zig").get_int_as_u32;
//const get_int_as_u64 = @import("zig_erl_bert/bert.zig").get_int_as_u64;

//const get_big_int_as_u128 = @import("zig_erl_bert/bert.zig").get_big_int_as_u128;

//const get_int_as_i8 = @import("zig_erl_bert/bert.zig").get_int_as_i8;
//const get_int_as_i16 = @import("zig_erl_bert/bert.zig").get_int_as_i16;
//const get_int_as_i32 = @import("zig_erl_bert/bert.zig").get_int_as_i32;
//const get_int_as_i64 = @import("zig_erl_bert/bert.zig").get_int_as_i64;

const get_float_as_f64 = @import("zig_erl_bert/bert.zig").get_float_as_f64;


pub fn main() !void{
  var gpa = std.heap.GeneralPurposeAllocator(.{}){};
  defer _ = gpa.deinit();
  const allocator = gpa.allocator();
  
  var arena = std.heap.ArenaAllocator.init(allocator);
  defer arena.deinit();
  const arena_alloc = arena.allocator();
  
  var bert = Bert.init(arena_alloc); // use arena allocator for automatic free memory
  
  const tuple01 = try bert.tuple(&.{
    try bert.atom("test"),
    bert.int(42),
    bert.float(3.14159),
    try bert.list(&.{
      bert.int(1),
      bert.int(2),
      bert.int(3),
    }),
    //try bert.binary( &[_]u8{ 0xDE, 0xAD, 0xBE, 0xEF } ),
    try bert.binary( &[_]u8{ 222, 173, 190, 239 } ), // same as previous line
    try bert.binary( "bamboleo" ), // try ascii - latin1
    try bert.binary( "🦀🦀🦀 тест" ), // try emoji + cyrillic
  });
  
  const encoded = try bert.encode(tuple01);
  print("Encoded: {any}\n", .{ encoded });
  
  const decoded = try bert.decode(encoded);
  //print("Decoded: {any}\n", .{ decoded }); // Decoded: zig_erl_bert.bert.Bert_Value{ .list = { zig_erl_bert.bert.Bert_Value{ .tuple = { ... } }, zig_erl_bert.bert.Bert_Value{ .tuple = { ... } } } }
  print("Decoded type: {s}\n", .{ @tagName(decoded) }); // tuple
  
  const tuple = try get_tuple(decoded); // []Bert_Value
  print("tuple length: {}\n", .{ tuple.len });
  
  const atom1_str = try get_atom_as_str( tuple[0] );
  print("atom: {s}\n", .{ atom1_str });
  
  const int0_u8 = try get_int_as_u8( tuple[1] );
  print("int0: {d}\n", .{ int0_u8 });
  
  const f_f64 = try get_float_as_f64( tuple[2] );
  //print("float: {d:.5}\n", .{ f_f64 });
  print("float: {}\n", .{ f_f64 });
  
  const list1 = try get_list( tuple[3] );
  print("list length: {}\n", .{ list1.len });
  
  const int1_u8 = try get_int_as_u8( list1[0] );
  print("int1: {d}\n", .{ int1_u8 });
  
  const int2_u8 = try get_int_as_u8( list1[1] );
  print("int2: {d}\n", .{ int2_u8 });
  
  const int3_u8 = try get_int_as_u8( list1[2] );
  print("int3: {d}\n", .{ int3_u8 });
  
  const binary1 = try get_binary_as_str( tuple[4] );
  print("binary1: {any}\n", .{ binary1 });
  
  const binary2 = try get_binary_as_str( tuple[5] );
  print("binary2: {any}\n", .{ binary2 });
  
  const binary3 = try get_binary_as_str( tuple[6] );
  print("binary3: {any}\n", .{ binary3 });
  
  const pretty = try format_bert(allocator, decoded);
  defer allocator.free(pretty);
  
  print("Decoded (Erlang style):\n{s}\n", .{pretty});
}


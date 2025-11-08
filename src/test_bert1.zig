
const std = @import("std");
const print = std.debug.print;

const Bert = @import("zig_erl_bert/bert.zig").Bert;
const format_bert = @import("zig_erl_bert/bert.zig").format_bert;

//const Bert_Get_Error = @import("zig_erl_bert/bert.zig").Bert_Get_Error;
const get_atom_as_str = @import("zig_erl_bert/bert.zig").get_atom_as_str;
const get_binary_as_str = @import("zig_erl_bert/bert.zig").get_binary_as_str;
const get_list = @import("zig_erl_bert/bert.zig").get_list;
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


pub fn main() !void{
  var gpa = std.heap.GeneralPurposeAllocator(.{}){};
  defer _ = gpa.deinit();
  const allocator = gpa.allocator();
  
  var bert = Bert.init(allocator);
  
  // create proplist: [{key1, 42}, {key2, <<"hello">>}]
  const pair1 = try bert.tuple(&.{
    try bert.atom("key1"),
    bert.int(42),
  });
  
  const pair2 = try bert.tuple(&.{
    try bert.atom("key2"),
    try bert.binary("hello"),
    //try bert.binary("hello_я"),
  });
  
  const proplist = try bert.list(&.{ pair1, pair2 });
  
  //print("Before encoding\n", .{});
  //print(" pair1: {any}\n", .{ pair1 });
  //print(" pair2: {any}\n", .{ pair2 });
  //print(" proplist: {any}\n", .{ proplist });
  
  const encoded = try bert.encode(proplist);
  print("Encoded: {any}\n", .{ encoded });
  
  const decoded = try bert.decode(encoded);
  //print("Decoded: {any}\n", .{ decoded }); // Decoded: zig_erl_bert.bert.Bert_Value{ .list = { zig_erl_bert.bert.Bert_Value{ .tuple = { ... } }, zig_erl_bert.bert.Bert_Value{ .tuple = { ... } } } }
  print("Decoded type: {s}\n", .{ @tagName(decoded) }); // list
  
  const list = try get_list(decoded); // []Bert_Value
  
  const tuple1 = list[0];
  const tuple2 = list[1];
  
  const key1   = try get_tuple_elem(tuple1, 0); // atom "key1"
  const value1 = try get_tuple_elem(tuple1, 1); // int 42
  
  const key2   = try get_tuple_elem(tuple2, 0); // atom "key2"
  const value2 = try get_tuple_elem(tuple2, 1); // binary
  
  // we can get value(s) like this
  //print("first key: {s}\n", .{ key1.atom }); // key1
  //print("first value: {d}\n", .{ value1.int }); // 42
  //print("second key: {s}\n", .{ key2.atom }); // key2
  ////print("second binary payload: {any}\n", .{ value2.binary }); // { 104, 101, 108, 108, 111 }
  //print("second binary payload: {s}\n", .{ value2.binary }); // hello
  
  // or get value(s) like this
  const key1_atom = try get_atom_as_str(key1);
  const value1_u8 = try get_int_as_u8(value1);
  
  const key2_atom = try get_atom_as_str(key2);
  const value2_str = try get_binary_as_str(value2);
  
  print("first key: {s}\n", .{ key1_atom });
  print("first value: {d}\n", .{ value1_u8 });
  print("second key: {s}\n", .{ key2_atom });
  print("second binary payload: {s}\n", .{ value2_str });
  
  const pretty = try format_bert(allocator, decoded);
  defer allocator.free(pretty);
  
  print("Decoded (Erlang style):\n{s}\n", .{ pretty });
}


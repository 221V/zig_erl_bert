# Zig Erlang BERT encode && decode data

```erlang
%% erlang

erlang:term_to_binary(X).
erlang:binary_to_term(Y).

> X = { test, 42, 3.14159, [1, 2, 3], <<222, 173, 190, 239>> }.
> io:format("~p~n", [term_to_binary(X)]).
<<131,104,5,100,0,4,116,101,115,116,97,42,70,64,9,33,249,240,27,134,110,107,0,3,1,2,3,109,0,0,0,4,222,173,190,239>>

> X2 = { test, 42, 3.14159, [1, 2, 3], <<"blabla">> }.
> io:format("~p~n", [term_to_binary( X2  )]).
<<131,104,5,100,0,4,116,101,115,116,97,42,70,64,9,33,249,240,27,134,110,107,0,3,1,2,3,109,0,0,0,6,98,108,97,98,108,97>>
```

```js
// js (check bert.js -- code from n2o v4.4 with fixes)

enc(tuple( atom('test'),  number(42), float(3.14159), list(1, 2, 3), bin( new Uint8Array([222, 173, 190, 239]) ) ) ); // bin('blabla'), bignum(bigInt(number))
// Uint8Array(39)[131,104,5,118,0,4,116,101,115,116,97,42,70,64,9,33,249,240,27,134,110,108,0,0,0,3,106,106,106,106,109,0,0,0,4,222,173,190,239]

enc(tuple( atom('test'),  number(42), float(3.14159), list(1, 2, 3), bin('blabla') ) );
// Uint8Array(41) [131,104,5,118,0,4,116,101,115,116,97,42,70,64,9,33,249,240,27,134,110,108,0,0,0,3,106,106,106,106,109,0,0,0,6,98,108,97,98,108,97]
```

```bash
zig 14.0.1

// check code examples - test_bert1.zig and test_bert2.zig


$ zig build-exe ./src/test_bert1.zig -O ReleaseFast -femit-bin=test_bert1
$ ./test_bert1
Encoded: { 131, 108, 0, 0, 0, 2, 104, 2, 118, 0, 4, 107, 101, 121, 49, 97, 42, 104, 2, 118, 0, 4, 107, 101, 121, 50, 109, 0, 0, 0, 5, 104, 101, 108, 108, 111, 106 }
Decoded type: list
first key: key1
first value: 42
second key: key2
second binary payload: hello
Decoded (Erlang style):
[{key1, 42}, {key2, <<"hello">>}]


$ zig build-exe ./src/test_bert2.zig -O ReleaseFast -femit-bin=test_bert2
$ ./test_bert2
Encoded: { 131, 104, 5, 118, 0, 4, 116, 101, 115, 116, 97, 42, 70, 64, 9, 33, 249, 240, 27, 134, 110, 108, 0, 0, 0, 3, 97, 1, 97, 2, 97, 3, 106, 109, 0, 0, 0, 4, 222, 173, 190, 239 }
Decoded type: tuple
tuple length: 5
atom: test
int0: 42
float: 3.14159e0
list length: 3
int1: 1
int2: 2
int3: 3
binary1: { 222, 173, 190, 239 }
Decoded (Erlang style):
{test, 42, 3.14159e0, [1, 2, 3], <<"��">>}

// todo think about "debug in erlang style" -
//   if uncomment - got u8 bytes list for cyrillic (latin1 shows correct only),
//   if commented like now - got this <<"��">> instead u8 bytes list <<222,173,190,239>>
```

```
// https://www.erlang.org/docs/25/apps/erts/erl_ext_dist.html
// https://www.erlang.org/doc/apps/erts/erl_ext_dist.html
SMALL_INTEGER_EXT = 97 // 1 = Int // Unsigned 8-bit integer
INTEGER_EXT = 98 // 4 = Int // Signed 32-bit integer in big-endian format
FLOAT_EXT = 99 // 31 = Float string
NEW_FLOAT_EXT = 70 // 8 = IEEE float // 8 bytes in big-endian IEEE format

SMALL_TUPLE_EXT = 104 // 1 = Arity, N = Elements // Arity field is an unsigned byte that determines how many elements that follows in section Elements
LARGE_TUPLE_EXT = 105 // 4 = Arity, N = Elements // Arity is an unsigned 4 byte integer in big-endian format
MAP_EXT = 116 // 4 = Arity, N = Pairs // Arity field is an unsigned 4 byte integer in big-endian format that determines the number of key-value pairs in the map
  // Key and value pairs (Ki => Vi) are encoded in section Pairs in the following order: K1, V1, K2, V2,..., Kn, Vn
  // Duplicate keys are not allowed within the same map

NIL_EXT = 106 // empty list, that is, the Erlang syntax []
STRING_EXT = 107 // 2 = Len, Len = Characters // lists of bytes (integer in the range 0-255) // field Len is an unsigned 2 byte integer (big-endian)
  //implementations must ensure that lists longer than 65535 elements are encoded as LIST_EXT
LIST_EXT = 108 // 4 = Len, Elements, Tail // Len is the number of elements that follows in section Elements
  // Tail is the final tail of the list; it is NIL_EXT for a proper list, but can be any type if the list is improper (for example, [a|b])

BINARY_EXT = 109 // 4 = Len, Len = Data // Len length field is an unsigned 4 byte integer (big-endian)
  // Binaries are generated with bit syntax expression or with erlang:list_to_binary/1, erlang:term_to_binary/1, or as input from binary ports

SMALL_BIG_EXT = 110 // 1 = n, 1 = Sign, n = d(0) ... d(n-1)
  // Bignums are stored in unary form with a Sign byte, that is, 0 if the bignum is positive and 1 if it is negative.
  // The digits are stored with the least significant byte stored first.
  // To calculate the integer, the following formula can be used:
  // B = 256
  // (d0*B^0 + d1*B^1 + d2*B^2 + ... d(N-1)*B^(n-1))
LARGE_BIG_EXT = 111 // 4 = n, 1 = Sign, n = d(0) ... d(n-1)

ATOM_UTF8_EXT = 118 // 2 = Len, Len = AtomName
SMALL_ATOM_UTF8_EXT = 119 // 1 = Len, Len = AtomName
ATOM_EXT (deprecated) = 100 // 2 = Len, Len = AtomName // 2 byte unsigned length in big-endian order, followed by Len numbers of 8-bit Latin-1 characters
  // that forms the AtomName
  // The maximum allowed value for Len is 255
SMALL_ATOM_EXT (deprecated) = 115 // 1 = Len, Len = AtomName // 1 byte unsigned length, followed by Len numbers of 8-bit Latin-1 characters that forms the AtomName

BIT_BINARY_EXT = 77 // 4 = Len, 1 = Bits, Len = Data
  // bitstring whose length in bits does not have to be a multiple of 8
  // Len field is an unsigned 4 byte integer (big-endian)
  // Bits field is the number of bits (1-8) that are used in the last byte in the data field, counting from the most significant bit to the least significant

ATOM_CACHE_REF = 82
PORT_EXT = 102
NEW_PORT_EXT = 89
V4_PORT_EXT = 120
PID_EXT = 103
NEW_PID_EXT = 88
REFERENCE_EXT (deprecated) = 101
NEW_REFERENCE_EXT = 114
NEWER_REFERENCE_EXT = 90
FUN_EXT (removed) = 117
NEW_FUN_EXT = 112
EXPORT_EXT = 113
LOCAL_EXT = 121
```


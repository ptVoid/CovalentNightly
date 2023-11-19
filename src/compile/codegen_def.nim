import ../runtime/vm_def

type
  OP*  = enum
    OP_CONSANTS = byte(0)
    TAG_INT
    TAG_FLOAT
    TAG_STR
    OP_LOAD_CONST
    OP_LOAD
    OP_ADD
    OP_SUB
    OP_MUL
    OP_DIV
  StaticType* = enum
    static_int
    static_str
    error
    dynamic
  Error = RootObj
  TypeMissmatch = object of Error
    left, right, expr: string
    
  Codegen* = object
    consants_count*: int16
    line*, colmun*: int
    consants*: seq[byte] 
    consant_objs*: seq[(consant, int16)]
    body*: seq[byte]


proc TypeMissmatchE*(this: Codegen,left, right, expr: string): StaticType =
  echo "type missmatch got left: " & left & " right: " & " in expr " & expr & "\n at " & $this.line & ":" & $this.colmun
  return error
var reg* = 0

proc emit*(bytes: var seq[byte],op: OP, reg0: int, reg1: int, reg2: int) =
  bytes.add(byte(op))
  bytes.add(byte(reg0))
  bytes.add(byte(reg1))
  bytes.add(byte(reg2))


proc emit*(bytes: var seq[byte],op: OP, reg0: int, byte0: byte, byte1: byte) =
  bytes.add(byte(op))
  bytes.add(byte(reg0))
  bytes.add(byte0)
  bytes.add(byte1)

proc emit*(bytes: var seq[byte],op: OP, reg0: int, imm: int | float) =
  bytes.add(byte(op))
  bytes.add(byte(reg0))
  bytes.add(byte(imm))

proc emit*(bytes: var seq[byte],tag: OP, value: seq[byte]) =
  bytes.add(byte(tag))
  bytes.add(value)
  


proc to4Bytes*(val: int | uint32 | int32): seq[byte] =
    var bytes: seq[byte] = @[]
    bytes.add(byte((val shr 24) and 0xFF))
    bytes.add(byte((val shr 16) and 0xFF))
    bytes.add(byte((val shr 8) and 0xFF))
    bytes.add(byte(val and 0xFF))
    return bytes

proc to2Bytes*(val: int16): seq[byte] =
    var bytes: seq[byte] = @[]
    bytes.add(byte((val shr 8) and 0xFF))
    bytes.add(byte(val and 0xFF))
    return bytes

proc addConst*(this: var Codegen, tag: OP,ctype: const_type ,bytes: seq[byte]): int16 =
  var aConsant = consant(ctype: ctype,bytes: bytes)    
  for key, val in this.consant_objs.items():
    if key == aConsant:
      return val
  
  this.consants.emit(tag, bytes)
  inc this.consants_count 
  this.consant_objs.add((aConsant, this.consants_count))
  return this.consants_count
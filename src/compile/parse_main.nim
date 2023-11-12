import tokenize
import AST
import options


type
  ScopeType = enum
    top,
    inside_func,
    inside_params,
    inside_call,
    variable_declaration_val,
    variable_assigment_val
  Scope = ref object
    parent: Option[Scope]
    Type: ScopeType
  Parser* = object
    line*, colmun*: int
    tokenizer: Tokenizer
    last_token: Token
    current_scope*: Scope
    current_node: Expr
proc mk_scope*(Type: ScopeType, parent: Option[Scope]): Scope =
  return Scope(parent: parent, Type: Type)

proc make_parser*(src: string): Parser =
  var parser = Parser(line: 1, colmun: 0, tokenizer: make_tokenizer(src))
  parser.last_token = parser.tokenizer.next()
  parser.current_scope = mk_scope(ScopeType.top, none(Scope))
  return parser

proc update*(this: var Parser) =
  this.line = this.tokenizer.line
  this.colmun = this.tokenizer.colmun

proc at*(this: var Parser): Token =
  this.update
  return this.tokenizer.current_token

proc take*(this: var Parser): Token =
  var prev = this.at
  this.last_token = prev
  discard this.tokenizer.next()
  return prev

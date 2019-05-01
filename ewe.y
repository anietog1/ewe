%token EOF
%token IDENTIFIER
%token INTEGER STRING

%token COLON ":" ASSIGN ":="
%token ADD "+" SUB "-" MUL "*" DIV "/" MOD "%"
%token GTEQ ">=" LTEQ "<=" DIFF "<>" GT ">" LT "<" EQ "="
%token READINT "readInt" WRITEINT "writeInt" READSTR "readStr" WRITESTR "writeStr"
%token LPAREN "(" RPAREN ")" COMMA ","
%token IF "if" THEN "then" GOTO "goto"
%token HALT "halt" BREAK "break"
%token EQU "equ" M "M" LBRACKET "[" RBRACKET "]"

%%

eweprog:
  executable equates EOF
  ;

executable:
    labeled_instruction
  | labeled_instruction executable
  ;

labeled_instruction:
    IDENTIFIER ":" labeled_instruction
  | instr
  ;

instr:
    memref ":=" INTEGER
  | memref ":=" STRING
  | memref ":=" "PC" "+" INTEGER
  | "PC" ":=" memref
  | memref ":=" memref
  | memref ":=" memref "+" memref
  | memref ":=" memref "-" memref
  | memref ":=" memref "*" memref
  | memref ":=" memref "/" memref
  | memref ":=" memref "%" memref
  | memref ":=" "M" "[" memref "+" INTEGER "]"
  | "M" "[" memref "+" INTEGER "]" ":=" memref
  | "readInt" "(" memref ")"
  | "writeInt" "(" memref ")"
  | "readStr" "(" memref "," memref ")"
  | "writeStr" "(" memref ")"
  | "goto" INTEGER
  | "goto" IDENTIFIER
  | "if" memref condition memref "then" "goto" INTEGER
  | "if" memref condition memref "then" "goto" IDENTIFIER
  | "halt"
  | "break"
  ;

equates:
    %empty
  | "equ" IDENTIFIER "M" "[" INTEGER "]" equates
  ;

memref:
    "M" "[" INTEGER "]"
  | IDENTIFIER
  ;

condition:
    ">="
  | ">"
  | "<="
  | "<"
  | "="
  | "<>"
  ;

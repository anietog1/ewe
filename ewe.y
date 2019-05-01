%token EOF
%token IDENTIFIER
%token INTEGER STRING

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

%%

"#"[^\n]* /* ignore comments */
[ \t\n]+  /* ignore whitespaces */

"+" { return ADD; }
"-" { return SUB; }
"*" { return MUL; }
"/" { return DIV; }
"%" { return MOD; }

">=" { return GTEQ; }
"<=" { return LTEQ; }
"<>" { return DIFF; }
">"  { return GT; }
"<"  { return LT; }
"="  { return EQ; }

"readInt"  { return READINT;  }
"writeInt" { return WRITEINT; }
"readStr"  { return READSTR;  }
"writeStr" { return WRITESTR; }

"(" { return LPAREN; }
")" { return RPAREN; }
"," { return COMMA;  }

"halt"  { return HALT; }
"break" { return BREAK; }

"M" { return M; }
"[" { return LBRACKET; }
"]" { return RBRACKET; }

[:digit:]+ { ; return INTEGER; }
[_[:alnum:]][_[:alnum:]]* { ; return IDENTIFIER; }
// \"[^\"]*\" { ; return STRING; }

. { }

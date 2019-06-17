%{
  #include <stdio.h>
  int yylex(void);
  void yyerror(char*);
  int yywrap(void);
%}
%token PC IDENTIFIER
%token INTEGER STRING

%token COLON ASSIGN
%token ADD SUB MUL DIV MOD
%token GTEQ LTEQ DIFF GT LT EQ
%token READINT WRITEINT READSTR WRITESTR
%token LPAREN RPAREN COMMA
%token IF THEN GOTO
%token HALT BREAK
%token EQU M LBRACKET RBRACKET

%%

eweprog:
  executable equates
  ;

executable:
    labeled_instruction
  | labeled_instruction executable
  ;

labeled_instruction:
    IDENTIFIER COLON labeled_instruction
  | instr
  ;

instr:
    memref ASSIGN INTEGER
  | memref ASSIGN STRING
  | memref ASSIGN PC ADD INTEGER
  | PC ASSIGN memref
  | memref ASSIGN memref
  | memref ASSIGN memref ADD memref
  | memref ASSIGN memref SUB memref
  | memref ASSIGN memref MUL memref
  | memref ASSIGN memref DIV memref
  | memref ASSIGN memref MOD memref
  | memref ASSIGN M LBRACKET memref ADD INTEGER RBRACKET
  | M LBRACKET memref ADD INTEGER RBRACKET ASSIGN memref
  | READINT LPAREN memref RPAREN
  | WRITEINT LPAREN memref RPAREN
  | READSTR LPAREN memref COMMA memref RPAREN
  | WRITESTR LPAREN memref RPAREN
  | GOTO INTEGER
  | GOTO IDENTIFIER
  | IF memref condition memref THEN GOTO INTEGER
  | IF memref condition memref THEN GOTO IDENTIFIER
  | HALT
  | BREAK
  ;

equates:
    EQU IDENTIFIER M LBRACKET INTEGER RBRACKET equates
  |
  ;

memref:
    M LBRACKET INTEGER RBRACKET
  | IDENTIFIER
  ;

condition:
    GTEQ
  | GT
  | LTEQ
  | LT
  | EQ
  | DIFF
  ;

%%

int main(void) {
 return yyparse();
}

void yyerror(char *s) {
  fprintf(stderr, "%s\n", s);
}

int yywrap(void) {
  return 1;
}

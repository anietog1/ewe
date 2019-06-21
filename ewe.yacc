%code requires {
  #include "ewe.h"
}

%{
  #include <stdio.h>
  int yylex(void);
  void yyerror(char *);
  int yywrap(void);
  int find_id(char *);
  int find_label(char *);
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

%union {
  ast_type type;
  ast *instr;
  int *memref;
  int val;
  char *str;
}

%type <memref> memref
%type <val> INTEGER
%type <instr> instr
%type <type> condition
%type <str> IDENTIFIER STRING

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
    memref ASSIGN INTEGER { $$ = integer($1, $3); }
  | memref ASSIGN STRING  { $$ = string($1, $3);  }
  | memref ASSIGN PC ADD INTEGER { $$ = readpc($1, $5); }
  | PC ASSIGN memref     { $$ = writepc($3);    }
  | memref ASSIGN memref { $$ = assign($1, $3); }
  | memref ASSIGN memref ADD memref { $$ = op(AST_ADD, $1, $3, $5); }
  | memref ASSIGN memref SUB memref { $$ = op(AST_SUB, $1, $3, $5); }
  | memref ASSIGN memref MUL memref { $$ = op(AST_MUL, $1, $3, $5); }
  | memref ASSIGN memref DIV memref { $$ = op(AST_DIV, $1, $3, $5); }
  | memref ASSIGN memref MOD memref { $$ = op(AST_MOD, $1, $3, $5); }
  | memref ASSIGN M LBRACKET memref ADD INTEGER RBRACKET { $$ = readindex($1, $5, $7); }
  | M LBRACKET memref ADD INTEGER RBRACKET ASSIGN memref { $$ = writeindex($3, $5, $8);  }
  | READINT LPAREN memref RPAREN  { $$ = readint($3);  }
  | WRITEINT LPAREN memref RPAREN { $$ = writeint($3); }
  | READSTR LPAREN memref COMMA memref RPAREN { $$ = readstr($3, $5); }
  | WRITESTR LPAREN memref RPAREN { $$ = writestr($3); }
  | GOTO INTEGER    { $$ = _goto($2); }
  | GOTO IDENTIFIER { $$ = _goto(find_label($2)); }
  | IF memref condition memref THEN GOTO INTEGER    { $$ = _if($3, $2, $4, $7); }
  | IF memref condition memref THEN GOTO IDENTIFIER { $$ = _if($3, $2, $4, find_label($7)); }
  | HALT  { $$ = just(AST_HALT);  }
  | BREAK { $$ = just(AST_BREAK); }
  ;

equates:
    EQU IDENTIFIER M LBRACKET INTEGER RBRACKET equates
  |
  ;

memref:
    M LBRACKET INTEGER RBRACKET { $$ = &mem[$3]; }
  | IDENTIFIER { $$ = &mem[find_id($1)]; }
  ;

condition:
    GTEQ  { $$ = AST_GTEQ; }
  | GT    { $$ = AST_GT;   }
  | LTEQ  { $$ = AST_LTEQ; } 
  | LT    { $$ = AST_LT;   }
  | EQ    { $$ = AST_EQ;   }
  | DIFF  { $$ = AST_DIFF; }
  ;

%%

void yyerror(char *s) {
  fprintf(stderr, "%s\n", s);
}

int yywrap(void) {
  return 1;
}

int main(void) {
  yyparse();
  run();
  return 0;
}

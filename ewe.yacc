%code requires {
  #include "ewe.h"
}

%{
  #include <stdio.h>
  #include <string.h>
  #include <stdlib.h>

  typedef struct pair {
    char *id;
    int val;
  } pair;

  #define IDVALUES_SIZE 1000
  #define LABELVALUES_SIZE 1000

  pair idvalues[IDVALUES_SIZE];
  int idvaluescnt = 0;
  pair labelvalues[LABELVALUES_SIZE];
  int labelvaluescnt = 0;

  int paircmp(const void *a, const void *b) {
    return strcmp(((pair *) a)->id, ((pair *) b)->id);
  }

  pair *new_pair(char *id, int val) {
    pair *tmp = malloc(sizeof(pair));
    tmp->id = id;
    tmp->val = val;
    return tmp;
  }

  void free_pair(pair *p) {
    free(p->id);
    free(p);
  }

  int yylex(void);
  void yyerror(char *);
  int yywrap(void);

  int get_id(char *);
  void set_id(char *, int);

  int get_label(char *);
  void set_label(char *, int);

  int instrscnt = 0;
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
    IDENTIFIER COLON labeled_instruction { set_label($1, instrscnt); }
  | instr { instrs[instrscnt++] = *$1; free($1); } /* free instead of free_ast as we need the string pointer */
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
  | GOTO INTEGER    { $$ = _goto($2 - 1); }
  | GOTO IDENTIFIER { $$ = _goto(get_label($2)); }
  | IF memref condition memref THEN GOTO INTEGER    { $$ = _if($3, $2, $4, $7 - 1); }
  | IF memref condition memref THEN GOTO IDENTIFIER { $$ = _if($3, $2, $4, get_label($7)); }
  | HALT  { $$ = just(AST_HALT);  }
  | BREAK { $$ = just(AST_BREAK); }
  ;

equates:
    EQU IDENTIFIER M LBRACKET INTEGER RBRACKET equates { set_id($2, $5); }
  | { qsort(idvalues, idvaluescnt, sizeof(pair), paircmp); }
  ;

memref:
    M LBRACKET INTEGER RBRACKET { $$ = &mem[$3]; }
  | IDENTIFIER { $$ = &mem[get_id($1)]; }
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

void set_id(char *id, int val) {
  idvalues[idvaluescnt].id = id;
  idvalues[idvaluescnt].val = val;
  ++idvaluescnt;
}

int get_id(char *id) {
  pair key;
  key.id = id;

  pair *found = bsearch(&key, idvalues, idvaluescnt, sizeof(pair), paircmp);
  return found->val;
}

void set_label(char *id, int val) {
  labelvalues[labelvaluescnt].id = id;
  labelvalues[labelvaluescnt].val = val;
  ++labelvaluescnt;
}

int get_label(char *lbl) {
  return 0;
}

int main(int argc, char **argv) {
  --argc, ++argv;

  if(argc == 0 || (argc == 1 && strcmp(argv[0], "-h") == 0)) {
    printf("Usage:\n    ewe FILE");
    return EXIT_SUCCESS;
  }

  extern FILE *yyin;
  yyin = fopen(argv[0], "r");

  if(yyin == NULL) {
    printf("File not found.");
    return EXIT_FAILURE;
  }

  if(yyparse() != 0) {
    fclose(yyin);
    return EXIT_FAILURE;
  }

  fclose(yyin);

  run();
  return EXIT_SUCCESS;
}

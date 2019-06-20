#ifndef EWE_H
#define EWE_H

#define EWE_MEM_SIZE 100000
#define EWE_INSTRS_SIZE 100000

typedef enum ast_type {
  AST_INTEGER, AST_STRING,
  AST_ADD, AST_SUB, AST_MUL, AST_DIV, AST_MOD,
  AST_GTEQ, AST_LTEQ, AST_DIFF, AST_GT, AST_LT, AST_EQ,
  AST_GOTO, AST_HALT, AST_BREAK,
  AST_READINT, AST_WRITEINT,
  AST_READSTR, AST_WRITESTR,
  AST_READPC, AST_WRITEPC,
  AST_READINDEX, AST_WRITEINDEX
} ast_type;

typedef struct ast {
  ast_type type;

  union {
    struct {
      /* INTEGER, STRING */
      /* ADD, SUB, MUL, DIV, MOD */
      int *dest;

      union {
        struct {
          int *a, *b;
        };

        int val;
        char *str;
      };
    } assign_fields;

    struct {
      /* WRITEPC, READPC */
      union {
        int *src, *dest;
      };

      /* READPC */
      int offset;
    } pc_fields;

    struct {
      /* WRITEINDEX, READINDEX */
      int *base, offset;

      union {
        int *src, *dest;
      };
    } index_fields;

    struct {
      /* GOTO */
      int dest;
    } goto_fields;

    struct {
      /* IF */
      int *a, *b;
      int dest;
    } if_fields;

    struct {
      /* READINT, WRITEINT, WRITESTR */
      union {
        int *dest, *src;
      };

      /* READSTR */
      int *len;
    } io_fields;
  };
} ast;

int pc = 0;
int mem[EWE_MEM_SIZE] = {};
ast instrs[EWE_INSTRS_SIZE] = {};

ast *just(ast_type);
ast *integer(int *, int);
ast *string(int *, char *);
ast *op(ast_type, int *, int *, int *);
ast *_if(ast_type, int *, int *, int);
ast *_goto(int);
ast *readint(int *);
ast *writeint(int *);
ast *readstr(int *, int *);
ast *writestr(int *);
ast *readpc(int);
ast *writepc(int *);
ast *readindex(int *, int);
ast *writeindex(int *, int, int *);

int eval(ast *);
void run(void);

#endif /* EWE_H */

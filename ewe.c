#include <stdio.h>
#include "ewe.h"

ast *just(ast_type type) {
  ast *tmp = (ast *) malloc(sizeof(ast));
  tmp->type = type;
  return tmp;
}

ast *integer(int *dest, int val) {
  ast *tmp = just(AST_INTEGER);
  tmp->assign_fields.dest = dest;
  tmp->assign_fields.val = val;
  return tmp;
}

ast *string(int *dest, char *str) {
  ast *tmp = just(AST_STRING);
  tmp->assign_fields.dest = dest;
  tmp->assign_fields.str = str;
  return tmp;
}

ast *assign(int *dest, int *src) {
  ast *tmp = just(AST_STRING);
  tmp->assign_fields.dest = dest;
  tmp->assign_fields.src = src;
  return tmp;
}

ast *op(ast_type type, int *dest, int *a, int *b) {
  ast *tmp = just(type);
  tmp->assign_fields.dest = dest;
  tmp->assign_fields.a = a;
  tmp->assign_fields.b = b;
  return tmp;
}

ast *_if(ast_type type, int *a, int *b, int dest) {
  ast *tmp = just(type);
  tmp->if_fields.a = a;
  tmp->if_fields.b = b;
  tmp->if_fields.dest = dest;
  return tmp;
}

ast *_goto(int dest) {
  ast *tmp = just(AST_GOTO);
  tmp->goto_fields.dest = dest;
  return tmp;
}

ast *readint(int *src) {
  ast *tmp = just(AST_READINT);
  tmp->io_fields.src = src;
  return tmp;
}

ast *writeint(int *src) {
  ast *tmp = just(AST_WRITEINT);
  tmp->io_fields.src = src;
  return tmp;
}

ast *readstr(int *dest, int *len) {
  ast *tmp = just(AST_READSTR);
  tmp->io_fields.dest = dest;
  tmp->io_fields.len = len;
  return tmp;
}

ast *writestr(int *src) {
  ast *tmp = just(AST_WRITESTR);
  tmp->io_fields.src = src;
  return tmp;
}

ast *readpc(int *dest, int offset) {
  ast *tmp = just(AST_READPC);
  tmp->pc_fields.dest = dest;
  tmp->pc_fields.offset = offset;
  return tmp;
}

ast *writepc(int *src) {
  ast *tmp = just(AST_WRITEPC);
  tmp->pc_fields.src = src;
  return tmp;
}

ast *readindex(int *base, int offset) {
  ast *tmp = just(AST_READINDEX);
  tmp->index_fields.base = base;
  tmp->index_fields.offset = offset;
  return tmp;
}

ast *writeindex(int *base, int offset, int *src) {
  ast *tmp = just(AST_WRITEINDEX);
  tmp->index_fields.base = base;
  tmp->index_fields.offset = offset;
  tmp->index_fields.src = src;
  return tmp;
}

void eval(ast *instr) {
  switch(instr->type) {
  case AST_INTEGER:
    *(instr->assign_fields.dest) = instr->assign_fields.val;
    break;
  case AST_STRING:
    for(int i = 0; instr->assign_fields.str[i] != '\0'; ++i) {
      instr->assign_fields.dest[i] = instr->assign_fields.str[i];
    }

    break;
  case AST_ASSIGN:
    *(instr->assign_fields.dest) = *(instr->assign_fields.src);
    break;
  case AST_ADD:
    *(instr->assign_fields.dest) = *(instr->assign_fields.a) + *(instr->assign_fields.b);
    break;
  case AST_SUB:
    *(instr->assign_fields.dest) = *(instr->assign_fields.a) - *(instr->assign_fields.b);
    break;
  case AST_MUL:
    *(instr->assign_fields.dest) = *(instr->assign_fields.a) * *(instr->assign_fields.b);
    break;
  case AST_DIV:
    *(instr->assign_fields.dest) = *(instr->assign_fields.a) / *(instr->assign_fields.b);
    break;
  case AST_MOD:
    *(instr->assign_fields.dest) = *(instr->assign_fields.a) % *(instr->assign_fields.b);
    break;
  case AST_GTEQ:
    if(*(instr->if_fields.a) >= *(instr->if_fields.b)) {
      pc = instr->if_fields.dest;
    }

    break;
  case AST_GT:
    if(*(instr->if_fields.a) > *(instr->if_fields.b)) {
      pc = instr->if_fields.dest;
    }

    break;
  case AST_LTEQ:
    if(*(instr->if_fields.a) <= *(instr->if_fields.b)) {
      pc = instr->if_fields.dest;
    }

    break;
  case AST_LT:
    if(*(instr->if_fields.a) < *(instr->if_fields.b)) {
      pc = instr->if_fields.dest;
    }

    break;
  case AST_EQ:
    if(*(instr->if_fields.a) == *(instr->if_fields.b)) {
      pc = instr->if_fields.dest;
    }

    break;
  case AST_DIFF:
    if(*(instr->if_fields.a) != *(instr->if_fields.b)) {
      pc = instr->if_fields.dest;
    }

    break;
  case AST_READINT:
    scanf(" %d", instr->io_fields.dest);
    break;
  case AST_WRITEINT:
    printf("%d\n", *(instr->io_fields.src));
    break;
  case AST_READSTR:
    for(int i = 0; i < *(instr->io_fields.len); ++i) {
      instr->io_fields.dest[i] = getchar();
    }

    instr->io_fields.dest[*(instr->io_fields.len)] = '\0';
    break;
  case AST_WRITESTR:
    {
      char str[EWE_MEM_SIZE / (sizeof(int) / sizeof(char))] = {};

      for(int i = 0; instr->io_fields.src[i] != '\0'; ++i) {
        str[i] = (char) instr->io_fields.src[i];
      }

      printf("%s", str);
      return 0;
    }
  case AST_READPC:
    *(instr->pc_fields.dest) = pc;
    break;
  case AST_WRITEPC:
    pc = *(instr->pc_fields.src) + instr->pc_fields.offset;
    break;
  case AST_READINDEX:
    *(instr->index_fields.dest) = mem[*(instr->index_fields.base) + instr->index_fields.offset];
    break;
  case AST_WRITEINDEX:
    mem[*(instr->index_fields.base) + instr->index_fields.offset] = *(instr->index_fields.src);
    break;
  case AST_HALT:
    /* do nothing */
    break;
  case AST_BREAK:
    printf("Press ENTER to continue.");
    while(getchar() != '\n');
    break;
  }
}

void run(void) {
  memset(mem, 0, EWE_MEM_SIZE);
  pc = 0;
  while(instrs[pc].type != AST_HALT) {
    eval(&instrs[pc++]);
  }
}

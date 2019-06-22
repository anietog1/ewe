%{
  #include "y.tab.h"
%}

%%

"#"[^\n]* /* ignore comments */
[ \t\n]+  /* ignore whitespaces */

":=" { return ASSIGN; }
":"  { return COLON;  }

"PC" { return PC; }

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

"if"   { return IF;   }
"then" { return THEN; }
"goto" { return GOTO; }

"halt"  { return HALT;  }
"break" { return BREAK; }

"equ" { return EQU; }
"M"   { return M;   }
"["   { return LBRACKET; }
"]"   { return RBRACKET; }

[0-9]+ { yylval.val = atoi(yytext); return INTEGER; }

\"[^\"]*\" {
  int n = strlen(yytext);
  yylval.str = (char *) malloc(sizeof(char) * (n - 2 + 1)); /* ignore quotes, add null character */
  strncpy(yylval.str, yytext + 1, n - 2); /* ignore quotes */
  yylval.str[n - 2 + 1] = '\0';
  return STRING;
}

[_a-zA-Z][_a-zA-Z0-9]* {
  int n =  strlen(yytext) + 1;
  yylval.str = (char *) malloc(sizeof(char) * n);
  strcpy(yylval.str, yytext);
  return IDENTIFIER;
}

<<EOF>> { return EOF; }

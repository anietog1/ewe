%%

"#"[^\n]* /* ignore comments */
[ \t\n]+  /* ignore whitespaces */

":=" { return ASSIGN; }
":"  { return COLON;  }

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

[:digit:]+ { return INTEGER; }
[_[:alnum:]][_[:alnum:]]* { return IDENTIFIER; }
\"([^\"]|\\\")*\" { return STRING; }

<<EOF>> { return EOF; }

ewe: ewe.yacc ewe.lex ewe.c ewe.h
	yacc -d ewe.yacc
	lex ewe.lex
	cc -o ewe y.tab.c lex.yy.c ewe.c

clean:
	rm -vf y.tab.h y.tab.c lex.yy.c ewe

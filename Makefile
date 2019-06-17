ewe: ewe.yacc ewe.lex
	yacc -d ewe.yacc
	lex ewe.lex
	cc y.tab.c lex.yy.c
	mv a.out ewe

clean:
	rm -vf y.tab.h y.tab.c lex.yy.c y.tab.o lex.yy.o ewe

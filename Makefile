ewe: main.c parser.y lexer.l
	flex lexer.l
	bison --defines=parser.h --output=parser.c parser.y
	cc main.c -o ewe

clean:
	rm -vf lexer.h lexer.c parser.h parser.c ewe

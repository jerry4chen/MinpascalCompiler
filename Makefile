all : lex yacc lex.yy.o node.o symtab.o	
	gcc -o minipascal y.tab.o node.o symtab.o -ll -ly

debug : lex yacc lex.yy.o node.o symtab.o	
	gcc -o minipascal y.tab.o node.o symtab.o -ll -ly -g

symtab.o : symtab.c
	gcc -c symtab.c

lex.yy.o : 
	gcc -c lex.yy.c -o lex.yy.o

lex : lex.l 
	lex lex.l

yacc : yacc.y
	yacc -d yacc.y
	gcc -c y.tab.c -o y.tab.o

#
#lex scan.l \
#&& yacc -d parse.y \
#&& gcc -c -o lex.yy.o lex.yy.c \
#&& gcc -c -o y.tab.o y.tab.c \
#&& gcc -c -o node.o node.c -std=gnu99 \
#&& gcc -c -o symtab.o symtab.c -std=gnu99 \
#&& gcc -o parse lex.yy.o y.tab.o node.o symtab.o -ll 
#
clean : 
	rm lex.yy.o y.tab.o node.o lex.yy.c y.tab.h y.tab.c

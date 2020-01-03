CC = gcc
L = flex
Y = yacc
LFLAG = -ll
YFLAG = -ly

TARGET = minicc

all: y.tab.c lex.yy.c y.tab.h
	$(CC) y.tab.c lex.yy.c  $(LFLAG) $(YFLAG) -o $(TARGET)

lex.yy.c: 1.l
	$(L) 1.l

y.tab.c: 1.y
	$(Y) -v -d 1.y

clean:
	rm -rf $(TARGET) y.tab.c lex.yy.c y.tab.h y.output

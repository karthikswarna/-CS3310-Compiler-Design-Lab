CC = gcc
LC = flex
CFLAGS = -ll

TARGET = scanner

all : lex.yy.c
	$(CC) lex.yy.c -o $(TARGET)

lex.yy.c : 3.l
	$(LC) 3.l

clean :
	rm -rf scanner lex.yy.c
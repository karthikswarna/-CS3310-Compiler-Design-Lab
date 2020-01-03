CC = gcc
LC = flex
CFLAGS = -ll

TARGET = scanner

all : lex.yy.c
	$(CC) lex.yy.c -o $(TARGET)

lex.yy.c : 4.l
	$(LC) 4.l

clean :
	rm -rf scanner lex.yy.c
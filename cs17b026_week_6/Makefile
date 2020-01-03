CC = g++
LC = flex
CFLAGS = -ll

TARGET = rdparser

all : lex.yy.c
	$(CC) lex.yy.c $(CFLAGS) -o $(TARGET)

lex.yy.c : 1.l
	$(LC) 1.l

clean :
	rm -rf $(TARGET) lex.yy.c
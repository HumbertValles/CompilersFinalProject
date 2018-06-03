#include "global.h"

int size = 0;
Symbol vars[100] = {NULL};

Symbol *lookup(const char *s)
{

	for (int x=0; x<size; x++) {
		if (strcmp(vars[x].lexptr, s)==0) {
			return &vars[x];
		}
	}
	return 0;
}

Symbol *insert(const char *s, int token)
{
	vars[size].lexptr = strdup(s);
	vars[size].token = token;
	size = size + 1;
	return &vars[size-1];
}

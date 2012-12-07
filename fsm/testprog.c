
#include <stdio.h>

#define STATE_INITIALIZE_CODE
typedef struct {
   int event;
   int state;
} STATE_TRANSITION;
#include "xx.output"

int main()
{
    printf ("begin\n");
    initstates();
    return 0;
}

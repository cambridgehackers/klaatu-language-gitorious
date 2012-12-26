
#include <stdio.h>
typedef struct {
   int event;
   int state;
} STATE_TRANSITION;
typedef struct {
    const char *name;
    STATE_TRANSITION *tran;
} STATE_TABLE_TYPE;

#define FSM_DEFINE_ENUMS
#define FSM_INITIALIZE_CODE
#include "xx.output"

int main()
{
    printf ("begin\n");
    android::initstates();
    return 0;
}

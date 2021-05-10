#include <stdio.h>

extern "C" int func(char *a);

int main(void)
{
  char text[]="nh:wind on the hill";
  int result;
  
  printf("Input string      > %s\n", text);
  result=func(text);
  printf("Conversion results> %s\n", text);
  
  return 0;
}

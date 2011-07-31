#include <time.h>
void save_to_history(char *uri);


void save_to_history(char *uri)
{
  char curdate[220], line[3000];
  time_t t = time(NULL);
  struct tm *ts = localtime(&t);
 printf("\ndate\n"); 
  strftime(curdate, 80, "%d:%m:%Y:%H:%M:%S", ts);
printf("\nline\n");
  sprintf(line,"%s::::%s\n",curdate,uri);
printf("\nweired\n");

  FILE *f;
  f = fopen(historyfile, "a+");
  fprintf(f, line);
  fclose(f);
}

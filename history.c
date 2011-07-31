#include <time.h>
void save_to_history(char *uri);


void save_to_history(char *uri)
{
  char curdate[220], line[3000];
  time_t t = time(NULL);
  struct tm *ts = localtime(&t);

  strftime(curdate, 80, "%d:%m:%Y:%H:%M:%S", ts);
  sprintf(line,"%s::::%s\n",curdate,uri);

  FILE *f;
  f = fopen(historyfile, "a+");
  fprintf(f, line);
  fclose(f);
}

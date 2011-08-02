void save_to_history(char *uri);

void save_to_history(char *uri)
{
  char curdate[25];
  time_t t = time(NULL);
  struct tm *ts = localtime(&t);

  strftime(curdate, 80, "%d:%m:%Y:%H:%M:%S", ts);

  FILE *f;
  f = fopen(historyfile, "a+");
  fprintf(f, curdate);
  fprintf(f, uri);
  fprintf(f, "\n");
  fclose(f);
}

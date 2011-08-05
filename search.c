void save_to_search_history(char *search);

void save_to_search_history(char *search)
{
  char curdate[25], *line;
  line = (char*)malloc(sizeof(char) * (strlen(search) + 40));
  time_t t = time(NULL);
  struct tm *ts = localtime(&t);

  strftime(curdate, 80, "%d:%m:%Y:%H:%M:%S", ts);
  sprintf(line,"%s::%s\n",curdate, search);

  FILE *f;
  f = fopen(searchfile, "a+");
  fprintf(f, line);
  fclose(f);
  free(line);
}

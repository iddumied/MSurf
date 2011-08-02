void set_bookmark(Client *c, const Arg *arg)
{  
  char curdate[25], *line, *uri = geturi(c);
  line = (char*)malloc(sizeof(char) * (strlen(uri)*2 + 40));
  time_t t = time(NULL);
  struct tm *ts = localtime(&t);

  strftime(curdate, 80, "%d:%m:%Y:%H:%M:%S", ts);
  sprintf(line,"%s::%s::%s\n",curdate, (char*)arg->v, uri);

  FILE *f;
  f = fopen(bookmarkfile, "a+");
  fprintf(f, line);
  fclose(f);
}

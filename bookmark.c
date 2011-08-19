void set_bookmark(Client *c, const Arg *arg)
{
  const gchar *title = webkit_web_view_get_title(c->view);
  char curdate[80], *line, *uri = geturi(c);

  line = (char*)malloc(sizeof(char) * (strlen(uri)*2 + 100));
  time_t t = time(NULL);
  struct tm *ts = localtime(&t);

  strftime(curdate, 80, "%d:%m:%Y:%H:%M:%S", ts);
  sprintf(line,"%s::%s::%s::",curdate, (char*)arg->v, (char*)title);

  FILE *f;
  f = fopen(bookmarkfile, "a+");
  fprintf(f, line);
  printf("\nsaved bookmark: %s\n",uri);
  fprintf(f,uri);
  fprintf(f,"\n");
  fclose(f);
  free(line);
}

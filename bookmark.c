void set_bookmark(Client *c, const Arg *arg)
{
  const gchar *title = webkit_web_view_get_title(c->view);
  char curdate[25], *line, *uri = geturi(c);
  line = (char*)malloc(sizeof(char) * (strlen(uri)*2 + 100));
  time_t t = time(NULL);
  struct tm *ts = localtime(&t);

  strftime(curdate, 80, "%d:%m:%Y:%H:%M:%S", ts);
  sprintf(line,"%s::%s::%s::%s\n",curdate, (char*)arg->v, (char*)title, uri);

  FILE *f;
  f = fopen(bookmarkfile, "a+");
  fprintf(f, line);
  fclose(f);
  free(line);
}

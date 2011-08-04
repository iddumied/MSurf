void save_to_history(Client *c);
Bool existFile(const char *fname);


void save_to_history(Client *c)
{
  const gchar *icon  = webkit_web_view_get_icon_uri(c->view);
  const gchar *title = webkit_web_view_get_title(c->view);
  if(*icon != NULL){
    WebKitNetworkRequest *request = webkit_network_request_new(icon);
    WebKitDownload *download = webkit_download_new(request);

    char filename[500];
    sprintf(filename,"/home/chief/.surf/.history/.icons/%s.ico",(char*)title);

    if(!existFile(filename)){
      const gchar *desturl = g_filename_to_uri(filename, NULL, NULL);
      webkit_download_set_destination_uri(download, desturl);
      webkit_download_start(download);
    }else printf("\nFile exist\n");
  }

  char curdate[25], *uri = geturi(c);
  time_t t = time(NULL);
  struct tm *ts = localtime(&t);

  strftime(curdate, 80, "%d:%m:%Y:%H:%M:%S::", ts);

  FILE *f;
  f = fopen(historyfile, "a+");
  fprintf(f, curdate);
  fprintf(f, (char*)title);
  fprintf(f, "::");
  fprintf(f, uri);
  fprintf(f, "\n");
  fclose(f);
}

Bool existFile(const char *fname)
{
  FILE * f= fopen (fname,"r");
    if (!f) return False;
    else {
      fclose(f); // dann ging's. Also wieder zu damit
      return True;
    } 
}



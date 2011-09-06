void save_to_history(Client *c);
Bool existFile(const char *fname);
void setup_home_path();


void save_to_history(Client *c)
{
  int i;
  const gchar *icon  = webkit_web_view_get_icon_uri(c->view);
  const gchar *title = webkit_web_view_get_title(c->view);
  if(*icon != NULL){
    WebKitNetworkRequest *request = webkit_network_request_new(icon);
    WebKitDownload *download = webkit_download_new(request);

    char filename[2000];
    sprintf(filename,"%s/.surf/.history/.icons/%s.ico", home_path, (char*)title);

    if(!existFile(filename)){
      const gchar *desturl = g_filename_to_uri(filename, NULL, NULL);
      webkit_download_set_destination_uri(download, desturl);
      webkit_download_start(download);
    }
  }

  char curdate[80], *uri = geturi(c);
  time_t t = time(NULL);
  struct tm *ts = localtime(&t);

  strftime(curdate, 80, "%d:%m:%Y:%H:%M:%S::", ts);

  FILE *f;
  f = fopen(historyfile, "a+");
  fprintf(f, curdate);
  fprintf(f, (char*)title);
  fprintf(f, "::");

  printf("\nOpend url: ");
  for(i = 0; i < strlen(uri);i++){ 
    printf("%c",uri[i]);
    fprintf(f,"%c", uri[i]);
  }
  printf("\n");
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

void setup_home_path()
{
  FILE *fp;
  char *line = NULL;
  size_t len = 0;
  ssize_t read;
  int i;
  fp = popen("echo $HOME","r");
  
   if((read = getline(&line,&len,fp)) != -1){
     home_path = (char*)malloc(sizeof(char)*len);
     for(i = 0;i < len;i++){
       if(line[i] == '\n'){
         home_path[i] = '\x00';
         break;
       }
       home_path[i] = line[i];
     }
   }

  fclose(fp);
}

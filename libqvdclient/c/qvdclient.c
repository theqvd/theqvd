#include <errno.h>
#include <unistd.h>
#include <stdlib.h>
#include <limits.h>
#include <string.h>
#include <openssl/ssl.h>
#include "qvdclient.h"

void help(const char *program)
{
  printf("%s [-?] [-d] -h host [-p port] -u username -w pass [-g wxh] [-f] \n", program);
  printf("  -? : shows this help\n");
  printf("  -v : shows version and exits\n");
  printf("  -d : Enables debugging\n");
  printf("  -h : indicates the host to connect to\n");
  printf("  -p : indicates the port to connect to, if not specified 8443 is used\n");
  printf("  -u : indicates the username for the connection\n");
  printf("  -w : indicates the password for the user\n");
  printf("  -g : indicates the geometry wxh. Example -g 1024x768\n");
  printf("  -f : Use fullscreen\n");
  printf("  -l : Use only list_of_vm (don't try to connect, useful for debugging)\n");
  printf("  -o : Assume One VM, that is connect always to the first VM (useful for debugging)\n");
  printf("  -n : No strict certificate checking, always accept certificate\n");
  printf("  -x : NX client options. Example: nx/nx,data=0,delta=0,cache=16384,pack=0:0\n");
  printf("  -c : Specify client certificate (PEM), it requires also -k. Example -c $HOME/.qvd/client.crt -k $HOME/.qvd/client.key\n");
  printf("  -k : Specify client certificate key (PEM), requires -c. Example $HOME/.qvd/client.crt -k $HOME/.qvd/client.key\n");
}

int parse_params(int argc, char **argv, const char **host, int *port, const char **user, const char **pass, const char **geometry, int *fullscreen, int *only_list_of_vm, int *one_vm, int *no_cert_check, const char **nx_options, const char **client_cert, const char **client_key)
{
  int opt, error = 0, version = 0;
  const char *program = argv[0];
  char *endptr;

  while ((opt = getopt(argc, argv, "?dvh:p:u:w:g:flonx:c:k:")) != -1 )
    {
      switch (opt)
	{
	case '?':
	  error = 1;
	  break;
	case 'v':
	  version = 1;
	  break;
	case 'd':
	  qvd_set_debug(2);
	  break;
	case 'h':
	  *host = optarg;
	  break;
	case 'p':
	  errno = 0;	  
	  *port = (int) strtol(optarg, &endptr, 10);
	  if ((errno == ERANGE && (*port == LONG_MAX || *port == LONG_MIN))
	      || optarg == endptr)
	      *port = -1;
	  break;
	case 'u':
	  *user = optarg;
	  break;
	case 'w':
	  *pass = optarg;
	  break;
	case 'g':
	  *geometry = optarg;
	  break;
	case 'f':
	  *fullscreen = 1;
	  break;
	case 'l':
	  *only_list_of_vm = 1;
	  break;
	case 'o':
	  *one_vm = 1;
	  break;
	case 'n':
	  *no_cert_check = 1;
	  break;
	case 'x':
	  *nx_options = optarg;
	  break;
	case 'c':
	  *client_cert = optarg;
	  break;
	case 'k':
	  *client_key = optarg;
	  break;
	default:
	  fprintf(stderr, "Parameter not recognized <%c>\n", opt);
	  error = 1;
	}
    }
  if (version) {
    printf("%s", qvd_get_version_text());
    exit(0);
  }
  if (*host == NULL)
    {
      fprintf(stderr, "The host paramter -h is required\n");
      error = 1;
    }
  if (*user == NULL)
    {
      fprintf(stderr, "The user paramter -u is required\n");
      error = 1;
    }
  if (*pass == NULL)
    {
      fprintf(stderr, "The password paramter -w is required\n");
      error = 1;
    }

  if (*port < 1 || *port > 65535)
    {
      fprintf(stderr, "The port parameter must be between 1 and 65535\n");
      error = 1;
    }

  if (*client_cert != NULL || *client_key != NULL)
    {

      if (*client_cert == NULL)
	{
	  fprintf(stderr, "If you specify -k then you must specify also -c\n");
	  error = 1;
	}
      else
	{
	  if (access(*client_cert, R_OK) != 0)
	    {
	      fprintf(stderr, "Cert file %s is not accessible: %s\n", *client_cert, strerror(errno));
	      error = 1;	      
	    }
	}
      
      if (*client_key == NULL)
	{
	  fprintf(stderr, "If you specify -c then you must specify also -k\n");
	  error = 1;
	}
      else
	{
	  if (access(*client_key, R_OK) != 0)
	    {
	      fprintf(stderr, "key file %s is not accessible: %s\n", *client_key, strerror(errno));
	      error = 1;	      
	    }
	}
    }

  if (error)
    help(program);

  return error;
}

#define YES_NO_SIZE 20
int accept_unknown_cert_callback(qvdclient *qvd, const char *cert_pem_str, const char *cert_pem_data)
{
  char answer[YES_NO_SIZE];
  int result;
  printf("Unknown cert:\n%s\n\nDo you want to accept it? ", cert_pem_str);
  scanf("%20s", answer);
  result = (strncmp(answer, "y", YES_NO_SIZE) == 0  || 
	    strncmp(answer, "yes", YES_NO_SIZE) == 0  || 
	    strncmp(answer, "Y", YES_NO_SIZE) == 0  || 
	    strncmp(answer, "Yes", YES_NO_SIZE) == 0  || 
	    strncmp(answer, "YES", YES_NO_SIZE) == 0);
  return result;
}


void print_vmids(vmlist *vm)
{
  vmlist *ptr;
  printf("List of vms:\n");
  for (ptr=vm; ptr != NULL; ptr = ptr->next)
    printf("VM ID:%d NAME:%s STATE:%s BLOCKED:%d\n", 
	   ptr->data->id, ptr->data->name, ptr->data->state, ptr->data->blocked);
}
int choose_vmid(vmlist *vm)
{
  int vm_id = -1;
  vmlist *ptr;

  while (vm_id == -1)
    {
      print_vmids(vm);

      printf("Choose vmid: ");
      scanf("%d", &vm_id);
      for (ptr=vm; ptr != NULL; ptr = ptr->next)
	if (ptr->data->id == vm_id)
	  {
	    printf("You have chosen VM ID:%d NAME:%s STATE:%s BLOCKED:%d\n", 
		   ptr->data->id, ptr->data->name, ptr->data->state, ptr->data->blocked);
	    return vm_id;
	  }
      printf("VM id not found. Please try again\n");
      vm_id = -1;
    }
}

int progress_callback(qvdclient *qvd, const char *message) {
  qvd_printf("Progress Callback: %s\n", message);
}

int _set_display_if_not_set(qvdclient *qvd) {
  char *display = getenv(DISPLAY_ENV);
  if (display == NULL || *display == '\0') {
    qvd_error(qvd, "The display variable was not set, setting %s to %s", DISPLAY_ENV, DEFAULT_DISPLAY);
    setenv(DISPLAY_ENV, DEFAULT_DISPLAY, 1);
    return 1;
  }
  return 0;
}


int qvd_connection(const char *host, int port, const char *user, const char *pass, const char *geometry, int fullscreen, int only_list_of_vm, int one_vm, int no_cert_check, const char *nx_options, const char *client_cert, const char *client_key) {
  int vm_id;
  qvdclient *qvd;

  qvd = qvd_init(host, port, user, pass);

  if (no_cert_check)
    qvd_set_no_cert_check(qvd);

  if (geometry)
    qvd_set_geometry(qvd, geometry);
  if (fullscreen)
    qvd_set_fullscreen(qvd);
  if (nx_options)
    qvd_set_nx_options(qvd, nx_options);

  qvd_set_cert_files(qvd, client_cert, client_key);

  qvd_set_unknown_cert_callback(qvd, accept_unknown_cert_callback);
  qvd_set_progress_callback(qvd, progress_callback);

  if (qvd_list_of_vm(qvd) == NULL)
    {
      printf("Error fetching vm for user %s in host %s: %s\n", user, host, qvd->error_buffer);
      qvd_free(qvd);
      return 5;
    }
  if (qvd->numvms <= 0)
    {
      printf("No vms found for user %s in host %s\n", user, host);
      qvd_free(qvd);
      return 2;
    }

  if (only_list_of_vm)
    {
      print_vmids(qvd->vmlist);
      printf("No more acctions, -l has been specified\n");
      return 0;
    }


  if (one_vm || qvd->numvms == 1)
    {
      vm_id = qvd->vmlist->data->id;
      printf("Connecting to the first vm: vm_id %d\n", vm_id);
    }
  else
    {
      vm_id = choose_vmid(qvd->vmlist);
    }
  if (vm_id < 0)
    {
      printf("Error choosing vm_id: %d\n", vm_id);
      return 6;
    }

  /* Set display if not set */
  _set_display_if_not_set(qvd);

  qvd_connect_to_vm(qvd, vm_id);
  printf("after qvd_connect_to_vm\n");
  qvd_free(qvd);
  return 0;


}

int main(int argc, char *argv[], char *envp[]) {
  const char *host = NULL, *user = NULL, *pass = NULL, *geometry = NULL, *nx_options = NULL, *cert_file = NULL, *key_file = NULL;
  int port = 8443, fullscreen=0, only_list_of_vm=0, one_vm=0, no_cert_check=0;
  int result, vm_id;
  if (parse_params(argc, argv, &host, &port, &user, &pass, &geometry, &fullscreen, &only_list_of_vm, &one_vm, &no_cert_check, &nx_options, &cert_file, &key_file))
    return 1;

  result = qvd_connection(host, port, user, pass, geometry, fullscreen, only_list_of_vm, one_vm, no_cert_check, nx_options, cert_file, key_file);

  return result;
}

/**********************************************************\

  Auto-generated npqvdAPI.cpp

\**********************************************************/

#include "JSObject.h"
#include "variant_list.h"
#include "DOM/Document.h"
#include "global/config.h"


// Pure hack to compile in MS Visual Studio with cygnwin headers, completely not
// portable
#ifdef QVD_FIREBREATH_WINDOWS
typedef struct
{
  int __count;
  union
  {
    wint_t __wch;
    unsigned char __wchb[4];
  };            /* Value so far.  */
//  } __value;            /* Value so far.  */
} _mbstate_t;
#define __mbstate_t_defined
#endif

#include "npqvdAPI.h"

///////////////////////////////////////////////////////////////////////////////
/// @fn FB::variant npqvdAPI::echo(const FB::variant& msg)
///
/// @brief  Echos whatever is passed from Javascript.
///         Go ahead and change it. See what happens!
///////////////////////////////////////////////////////////////////////////////
FB::variant npqvdAPI::echo(const FB::variant& msg)
{
    static int n(0);
    fire_echo("So far, you clicked this many times: ", n++);

    // return "foobar";
    return msg;
}

///////////////////////////////////////////////////////////////////////////////
/// @fn npqvdPtr npqvdAPI::getPlugin()
///
/// @brief  Gets a reference to the plugin that was passed in when the object
///         was created.  If the plugin has already been released then this
///         will throw a FB::script_error that will be translated into a
///         javascript exception in the page.
///////////////////////////////////////////////////////////////////////////////
npqvdPtr npqvdAPI::getPlugin()
{
    npqvdPtr plugin(m_plugin.lock());
    if (!plugin) {
        throw FB::script_error("The plugin is invalid");
    }
    return plugin;
}

// Read/Write property testString
std::string npqvdAPI::get_testString()
{
    return m_testString;
}

void npqvdAPI::set_testString(const std::string& val)
{
    m_testString = val;
}

// Read-only property version
std::string npqvdAPI::get_version()
{
    return FBSTRING_PLUGIN_VERSION;
}

void npqvdAPI::testEvent()
{
    fire_test();
}

// QVD Method
const char *npqvdAPI::npqvd_get_version_text()
{
  return qvd_get_version_text();
}

int npqvdAPI::npqvd_get_version()
{
  return qvd_get_version();
}

void npqvdAPI::npqvd_init(std::string host, int port, std::string username, std::string password)
{
  qvd = qvd_init(host.c_str(), port, username.c_str(), password.c_str());
  qvd->userdata=this;
}

std::vector<std::map<std::string,std::string> > npqvdAPI::npqvd_list_of_vm()
{
  std::vector< std::map<std::string,std::string> > myreturn;
  vmlist *vmlist, *ptr;

  if (qvd == NULL)
    {
      qvd_printf("Error qvd is null qvd_init has not been called");
      return myreturn;
    }
  vmlist = qvd_list_of_vm(qvd);
  if (vmlist == NULL)
    {
      qvd_error(qvd, "Error fetching vm list for user %s in host %s: %s\n", qvd->username, qvd->hostname, qvd->error_buffer);
      return myreturn;
    }

  for (ptr=vmlist; ptr != NULL; ptr = ptr->next)
    {
      std::map<std::string,std::string> vm;
      std::stringstream sid, sblocked;
      std::string name(ptr->data->name);
      std::string state(ptr->data->state);

      sid << ptr->data->id;
      sblocked << ptr->data->blocked;
      vm["id"] = sid.str();
      vm["name"] = name;
      vm["state"] = state;
      vm["blocked"] = sblocked.str();
      myreturn.push_back(vm);
      qvd_printf("VM ID:%d NAME:%s STATE:%s BLOCKED:%d\n", 
		 ptr->data->id, ptr->data->name, ptr->data->state, ptr->data->blocked);
      
    }

  return myreturn;
}

int npqvdAPI::npqvd_connect_to_vm(int vmid_param)
{
  if (qvd == NULL)
    {
      qvd_printf("Error qvd is null qvd_init has not been called");
      return 0;
    }
  /*  qvd_set_display(qvd, ":0"); */
  qvd_printf("Connecting to vmid: %d\n", vmid);
  vmid=vmid_param;
#if defined(__unix__)
  if ((qvdpid = fork()) == 0)
    {
      // Child
      // After a fork no connection can be done to popup the cert validation
      // But it should be validated beforehand with the qvd_get_vm_list
      qvd_printf("Inside fork with pid %d", getpid());
      qvd_set_no_cert_check(qvd);
      qvd_connect_to_vm(qvd, vmid);
      return 1;
    }
  else
    {
      qvd_printf("Fork initiated (parent). The pid is %d", qvdpid);
      return 1;
    }
#else
  if (connection_established)
    {
      qvd_error(qvd, "Currently only one connection is allowed. Close the current connection and open another");
      return 0;
    }
  else
    {
      connection_established = 1;
      boost::thread t(boost::bind(&npqvdAPI::npqvd_connect_to_vm_thread,
				  this));
      return 0;
    }
#endif
}

void npqvdAPI::npqvd_connect_to_vm_thread()
{
      qvd_connect_to_vm(qvd, vmid);
}

void npqvdAPI::npqvd_list_of_vm_async(const FB::JSObjectPtr &callback)
{
  boost::thread t(boost::bind(&npqvdAPI::npqvd_list_of_vm_async_thread,
         this, callback));
  connect_thread = &t;
}

void npqvdAPI::npqvd_list_of_vm_async_thread(const FB::JSObjectPtr &callback)
{
  std::vector< std::map<std::string,std::string> > vmlist = npqvd_list_of_vm();
  callback->InvokeAsync("", FB::variant_list_of(shared_from_this())(vmlist));
}

static int npqvd_progress(qvdclient *qvd, const char *message)
{
  std::string strmessage(message);
  qvd_printf("Invoked npqvd_progress with message %s, %s\n", message, strmessage.c_str());

  npqvdAPI *npqvdapi = (npqvdAPI *)qvd->userdata;
  //  const FB::JSObjectPtr callback = npqvdapi->progressCallback;
  npqvdapi->progressCallback->InvokeAsync("", FB::variant_list_of(npqvdapi->shared_from_this())(strmessage));

  return 0;
}

void npqvdAPI::npqvd_set_progress_callback(const FB::JSObjectPtr &callback)
{
  if (qvd == NULL)
    {
      qvd_printf("Error in npqvd_set_progress_callback qvd is null qvd_init has not been called");
      return;
    }
  progressCallback = FB::JSObjectPtr(callback);
  qvd->userdata = (void *)this;
  qvd_printf("Setting progress callback in qvd %p to %p\n", qvd, npqvd_progress);
  qvd_set_progress_callback(qvd, npqvd_progress);
}

static int npqvd_unknown_cert_callback(qvdclient *qvd, const char *cert_pem_str, const char *cert_pem_data)
{
  int intresult = 0;
  std::string str_pem_str(cert_pem_str);
  std::string str_pem_data(cert_pem_data);
  qvd_printf("Invoked npqvd_unknown_cert_callback with cert str %s and data\n", str_pem_str.c_str(), str_pem_data.c_str());

  npqvdAPI *npqvdapi = (npqvdAPI *)qvd->userdata;
  FB::variant result = npqvdapi->certCheckCallback->Invoke("", FB::variant_list_of(npqvdapi->shared_from_this())(str_pem_str)(str_pem_data));
  if (result.is_of_type<bool>())
    {
      intresult = result.cast<bool>();
      qvd_printf("npqvd_unknown_cert_callback result is %d", intresult);
    }
  else
    qvd_printf("npqvd_unknown_cert_callback result is not of type int returning %d", intresult);
    
  return intresult;
}

void npqvdAPI::npqvd_set_unknown_cert_callback(const FB::JSObjectPtr &callback)
{
  if (qvd == NULL)
    {
      qvd_printf("Error in npqvd_set_unknown_cert_callback qvd is null qvd_init has not been called");
      return;
    }
  certCheckCallback = FB::JSObjectPtr(callback);
  qvd->userdata = (void *)this;
  qvd_printf("Setting cert check callback in qvd %p to %p\n", qvd, npqvd_progress);
  qvd_set_unknown_cert_callback(qvd, npqvd_unknown_cert_callback);
}


void npqvdAPI::npqvd_set_geometry(std::string geometry)
{
  if (qvd == NULL)
    {
      qvd_printf("Error in npqvd_set_geometry qvd is null, qvd_init has not been called");
      return;
    }
  qvd_set_geometry(qvd, geometry.c_str());
}

void npqvdAPI::npqvd_set_fullscreen()
{
  if (qvd == NULL)
    {
      qvd_printf("Error in npqvd_set_fullscreen qvd is null, qvd_init has not been called");
      return;
    }
  qvd_set_fullscreen(qvd);
}


void npqvdAPI::npqvd_set_nofullscreen()
{
  if (qvd == NULL)
    {
      qvd_printf("Error in npqvd_set_nofullscreen qvd is null, qvd_init has not been called");
      return;
    }
  qvd_set_nofullscreen(qvd);
}

void npqvdAPI::npqvd_set_debug()
{
  qvd_set_debug();
}

void npqvdAPI::npqvd_set_display(std::string display)
{
  if (qvd == NULL)
    {
      qvd_printf("Error in npqvd_set_display qvd is null, qvd_init has not been called");
      return;
    }
  qvd_set_display(qvd, display.c_str());
}

void npqvdAPI::npqvd_set_home(std::string home)
{
  if (qvd == NULL)
    {
      qvd_printf("Error in npqvd_set_home qvd is null, qvd_init has not been called");
      return;
    }
  qvd_set_home(qvd, home.c_str());
}

void npqvdAPI::npqvd_set_useragent(std::string useragent)
{
  if (qvd == NULL)
    {
      qvd_printf("Error in npqvd_set_useragent qvd is null, qvd_init has not been called");
      return;
    }
  qvd_set_useragent(qvd, useragent.c_str());
}

void npqvdAPI::npqvd_set_os(std::string os)
{
  if (qvd == NULL)
    {
      qvd_printf("Error in npqvd_set_os qvd is null, qvd_init has not been called");
      return;
    }
  qvd_set_os(qvd, os.c_str());
}

void npqvdAPI::npqvd_set_link(std::string link)
{
  if (qvd == NULL)
    {
      qvd_printf("Error in npqvd_set_link qvd is null, qvd_init has not been called");
      return;
    }
  qvd_set_link(qvd, link.c_str());
}

void npqvdAPI::npqvd_set_no_cert_check()
{
  if (qvd == NULL)
    {
      qvd_printf("Error in npqvd_set_no_cert_check qvd is null, qvd_init has not been called");
      return;
    }
  qvd_set_no_cert_check(qvd);
}

void npqvdAPI::npqvd_set_strict_cert_check()
{
  if (qvd == NULL)
    {
      qvd_printf("Error in npqvd_set_strict_cert_check qvd is null, qvd_init has not been called");
      return;
    }
  qvd_set_strict_cert_check(qvd);
}

void npqvdAPI::npqvd_set_nx_options(std::string options)
{
  if (qvd == NULL)
    {
      qvd_printf("Error in npqvd_set_nx_options qvd is null, qvd_init has not been called");
      return;
    }
  qvd_set_nx_options(qvd, options.c_str());
}

void npqvdAPI::npqvd_set_cert_files(std::string client_cert, std::string client_key)
{
  if (qvd == NULL)
    {
      qvd_printf("Error in npqvd_set_cert_files qvd is null, qvd_init has not been called");
      return;
    }
  qvd_set_cert_files(qvd, client_cert.c_str(), client_key.c_str());
}

std::string npqvdAPI::npqvd_get_last_error()
{
  if (qvd == NULL)
    {
      qvd_printf("Error in npqvd_get_last_error qvd is null, qvd_init has not been called");
      return std::string("");
    }
  char *s = qvd_get_last_error(qvd);
  std::string last_error(s);
  return last_error;
}

void npqvdAPI::npqvd_end_connection()
{
#if defined(__unix__)
  // Run kill
  if (qvdpid != 0)
    {
      qvd_printf("~npqvd_end_connection: killing pid: %d\n", qvdpid);
      kill(qvdpid, 9);
      qvdpid = 0;
    }
#else
  if (qvd == NULL)
    {
      qvd_printf("Error in npqvd_end_connection qvd is null, qvd_init has not been called");
      return;
    }
  qvd_end_connection(qvd);
  connection_established = 0;
#endif
}


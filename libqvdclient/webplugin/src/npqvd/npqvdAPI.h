 /**********************************************************\

  Auto-generated npqvdAPI.h

\**********************************************************/

#include <string>
#include <sstream>
#include <boost/weak_ptr.hpp>
#include <signal.h>
#include "JSAPIAuto.h"
#include "BrowserHost.h"
#include "npqvd.h"

#ifndef H_npqvdAPI
#define H_npqvdAPI

class npqvdAPI : public FB::JSAPIAuto
{
public:
    ////////////////////////////////////////////////////////////////////////////
    /// @fn npqvdAPI::npqvdAPI(const npqvdPtr& plugin, const FB::BrowserHostPtr host)
    ///
    /// @brief  Constructor for your JSAPI object.
    ///         You should register your methods, properties, and events
    ///         that should be accessible to Javascript from here.
    ///
    /// @see FB::JSAPIAuto::registerMethod
    /// @see FB::JSAPIAuto::registerProperty
    /// @see FB::JSAPIAuto::registerEvent
    ////////////////////////////////////////////////////////////////////////////
    npqvdAPI(const npqvdPtr& plugin, const FB::BrowserHostPtr& host) :
        m_plugin(plugin), m_host(host)
    {
        registerMethod("echo",      make_method(this, &npqvdAPI::echo));
        registerMethod("testEvent", make_method(this, &npqvdAPI::testEvent));
        registerMethod("qvd_get_version_text", make_method(this, &npqvdAPI::npqvd_get_version_text));
        registerMethod("qvd_get_version", make_method(this, &npqvdAPI::npqvd_get_version));
        registerMethod("qvd_init", make_method(this, &npqvdAPI::npqvd_init));
	/*       registerMethod("qvd_list_of_vm_old", make_method(this, &npqvdAPI::npqvd_list_of_vm_old)); */
        registerMethod("qvd_connect_to_vm", make_method(this, &npqvdAPI::npqvd_connect_to_vm));
        registerMethod("qvd_list_of_vm", make_method(this, &npqvdAPI::npqvd_list_of_vm_async));
        registerMethod("qvd_set_progress_callback", make_method(this, &npqvdAPI::npqvd_set_progress_callback));
        registerMethod("qvd_set_unknown_cert_callback", make_method(this, &npqvdAPI::npqvd_set_unknown_cert_callback));
        registerMethod("qvd_set_geometry", make_method(this, &npqvdAPI::npqvd_set_geometry));
        registerMethod("qvd_set_fullscreen", make_method(this, &npqvdAPI::npqvd_set_fullscreen));
        registerMethod("qvd_set_nofullscreen", make_method(this, &npqvdAPI::npqvd_set_nofullscreen));
        registerMethod("qvd_set_debug", make_method(this, &npqvdAPI::npqvd_set_debug));
        registerMethod("qvd_set_display", make_method(this, &npqvdAPI::npqvd_set_display));
        registerMethod("qvd_set_home", make_method(this, &npqvdAPI::npqvd_set_home));
        registerMethod("qvd_set_useragent", make_method(this, &npqvdAPI::npqvd_set_useragent));
        registerMethod("qvd_set_os", make_method(this, &npqvdAPI::npqvd_set_os));
        registerMethod("qvd_set_link", make_method(this, &npqvdAPI::npqvd_set_link));
        registerMethod("qvd_set_no_cert_check", make_method(this, &npqvdAPI::npqvd_set_no_cert_check));
        registerMethod("qvd_set_strict_cert_check", make_method(this, &npqvdAPI::npqvd_set_strict_cert_check));
        registerMethod("qvd_set_nx_options", make_method(this, &npqvdAPI::npqvd_set_nx_options));
        registerMethod("qvd_set_cert_files", make_method(this, &npqvdAPI::npqvd_set_cert_files));
        registerMethod("qvd_get_last_error", make_method(this, &npqvdAPI::npqvd_get_last_error));
        registerMethod("qvd_end_connection", make_method(this, &npqvdAPI::npqvd_end_connection));
	
        // Read-write property
        registerProperty("testString",
                         make_property(this,
                                       &npqvdAPI::get_testString,
                                       &npqvdAPI::set_testString));
        
        // Read-only property
        registerProperty("version",
                         make_property(this,
                                       &npqvdAPI::get_version));
	qvd = NULL;
	vmid = 0;
	connect_thread = NULL;
#ifdef __unix__
	qvdpid = 0;
#endif
    }

    ///////////////////////////////////////////////////////////////////////////////
    /// @fn npqvdAPI::~npqvdAPI()
    ///
    /// @brief  Destructor.  Remember that this object will not be released until
    ///         the browser is done with it; this will almost definitely be after
    ///         the plugin is released.
    ///////////////////////////////////////////////////////////////////////////////
    ~npqvdAPI() {
#if defined(__unix__) || defined(__APPLE__)
      if (qvdpid != 0)
      	{
      	  qvd_printf("~npqvdAPI: NPP_Destroy killing pid: %d\n", qvdpid);
      	  kill(qvdpid, 9);
      	  qvdpid = 0;
      	}
#else
      if (connect_thread)
	{
	  qvd_printf("Interrupting connect thread %p", connect_thread);
	  qvd_end_connection(qvd);
	  connect_thread->join();
	}
#endif
      if (qvd != NULL)
	{
	  qvd_free(qvd);
	  qvd = NULL;
	}
      
    };

    npqvdPtr getPlugin();

    // Read/Write property ${PROPERTY.ident}
    std::string get_testString();
    void set_testString(const std::string& val);

    // Read-only property ${PROPERTY.ident}
    std::string get_version();

    // method wrapper
    const char *npqvd_get_version_text();
    int npqvd_get_version();
    void npqvd_init(std::string host, int port, std::string username, std::string password);
    void npqvd_connect_to_vm(int vmid);
    void npqvd_list_of_vm_async(const FB::JSObjectPtr &callback);
    void npqvd_set_progress_callback(const FB::JSObjectPtr &callback);
    void npqvd_set_unknown_cert_callback(const FB::JSObjectPtr &callback);
    void npqvd_set_geometry(std::string geometry);
    void npqvd_set_fullscreen();
    void npqvd_set_nofullscreen();
    void npqvd_set_debug();
    void npqvd_set_display(std::string display);
    void npqvd_set_home(std::string home);
    void npqvd_set_useragent(std::string useragent);
    void npqvd_set_os(std::string os);
    void npqvd_set_link(std::string link);
    void npqvd_set_no_cert_check();
    void npqvd_set_strict_cert_check();
    void npqvd_set_nx_options(std::string options);
    void npqvd_set_cert_files(std::string client_cert, std::string client_key);
    std::string npqvd_get_last_error();
    void npqvd_end_connection();
    // Method echo
    FB::variant echo(const FB::variant& msg);
    
    // Event helpers
    FB_JSAPI_EVENT(test, 0, ());
    FB_JSAPI_EVENT(echo, 2, (const FB::variant&, const int));

    // Method test-event
    void testEvent();
    FB::JSObjectPtr progressCallback;
    FB::JSObjectPtr certCheckCallback;


private:
    npqvdWeakPtr m_plugin;
    FB::BrowserHostPtr m_host;

    std::string m_testString;
    qvdclient *qvd;
#ifdef __unix__
    pid_t qvdpid;
#endif
    int vmid;
    void npqvd_list_of_vm_async_thread(const FB::JSObjectPtr &callback);
    std::vector<std::map<std::string,std::string> > npqvd_list_of_vm();
    void npqvd_connect_to_vm_thread();
    boost::thread *connect_thread;

};

#endif // H_npqvdAPI


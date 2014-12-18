package com.theqvd.client.jqvdclient;


import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;

import org.kohsuke.args4j.CmdLineException;
import org.kohsuke.args4j.CmdLineParser;
import org.kohsuke.args4j.Option;
import org.kohsuke.args4j.spi.BooleanOptionHandler;
import org.kohsuke.args4j.spi.IntOptionHandler;

import com.theqvd.client.jni.QvdException;
import com.theqvd.client.jni.QvdProgressHandler;
import com.theqvd.client.jni.QvdclientWrapper;
import com.theqvd.client.jni.Vm;

public class Jqvdclient {
	@Option(name="-d",usage="debug")
    private boolean debug=false;
	@Option(name="-v",usage="version")
    private boolean version=false;
	@Option(name="-h",usage="Remote host")
    private String host;
	@Option(name="-p",usage="Remote port")
    private int port = 8443;
	@Option(name="-u",usage="username")
	private String user;
	@Option(name="-w",usage="password")
    private String password;
	@Option(name="-W",handler=IntOptionHandler.class,usage="Width")
    private int width = -1;
	@Option(name="-H",handler=IntOptionHandler.class,usage="Height")
    private int height = -1;
	@Option(name="-f",handler=BooleanOptionHandler.class,usage="fullscreen")
    private boolean fullscreen = false;
	@Option(name="-l",handler=BooleanOptionHandler.class,usage="List of VM (don't run connect_to_vm)")
    private boolean list_vm_only = false;
	@Option(name="-o",handler=BooleanOptionHandler.class,usage="Only one VM (choose the first VM for connection)")
    private boolean use_first_vm = false;
	@Option(name="-n",handler=BooleanOptionHandler.class,usage="No certificate check (accept any certificate)")
    private boolean no_certificate_check = false;
	@Option(name="-x",usage="NX client options. Example: nx/nx,data=0,delta=0,cache=16384,pack=0:0")
    private String nx_options = "";
	@Option(name="-r",handler=BooleanOptionHandler.class,usage="Progress handler, shows progress from HKD")
    private boolean progress = false;
	@Option(name="-c",usage="Client cert file, PEM format")
    private String client_cert;
	@Option(name="-k",usage="Client key file")
    private String client_key;
	/**
	 * @param args
	 * @throws IOException 
	 */
//	@Argument
//    private List<String> arguments = new ArrayList<String>();

	public static void main(String[] args) throws IOException, QvdException {
		new Jqvdclient().doMain(args);
	}

	public void doMain(String[] args) throws IOException, QvdException {
		CmdLineParser parser = new CmdLineParser(this);
		try {
            // parse the arguments.
            parser.parseArgument(args);

            // you can parse additional arguments if you want.
            // parser.parseArgument("more","args");
            if (version) {
        		System.out.print(QvdclientWrapper.get_version_text());
            	return;
            }
            // after parsing arguments, you should check
            // if enough arguments are given.
            if(host == null || user == null || password == null || host.isEmpty() || user.isEmpty() || password.isEmpty() )
                throw new CmdLineException(parser, "No argument is given");

        } catch( CmdLineException e ) {
            // if there's a problem in the command line,
            // you'll get this exception. this will report
            // an error message.
            System.err.println(e.getMessage());
            System.err.println("java SampleMain [options...] arguments...");
            // print the list of available options
            parser.printUsage(System.err);
            System.err.println();

            // print option sample. This is useful some time
            System.err.println(" Example: java SampleMain"+parser.printExample(org.kohsuke.args4j.ExampleMode.ALL));

            return;
        }
			
		connect();
		
		return ;
	}
	
	void connect() throws QvdException, IOException {
		int i;
		AcceptUnknownCertHandler unknown_cert_handler = new AcceptUnknownCertHandler();
		QvdProgressHandler progress_handler = new PrintProgress();
		QvdclientWrapper q = new QvdclientWrapper();
		
		if (debug) {
			q.qvd_set_debug();
		}
		q.qvd_init(host, port, user, password);
		if (width != -1 && height != -1) {
			q.qvd_set_geometry(width, height);
		}
		if (fullscreen) {
			q.qvd_set_fullscreen();
		}
		if (nx_options != null && !nx_options.isEmpty()) {
			q.qvd_set_nx_options(nx_options);
		}
		q.qvd_set_certificate_handler_callback(unknown_cert_handler);
		if (this.no_certificate_check) {
			q.qvd_set_no_cert_check();
		}
		if (progress) {
			System.out.println("The progress handler is set to "+progress_handler);
			q.qvd_set_progress_handler_callback(progress_handler);
		}
		if (client_cert != null && client_key != null) {
			q.qvd_set_cert_files(client_cert, client_key);
		}
		q.qvd_list_of_vm();
		Vm vmlist[] = q.getQvdclient().getVmlist();
		System.out.println("Payment required is "+q.qvd_payment_required());
		if (q.qvd_payment_required()) {
			System.err.println("QVD payment required");
			q.qvd_free();
			return ;
		}
		if (vmlist.length == 0) {
			System.err.println("No VM available. Num of vms:" + vmlist.length);
			q.qvd_free();
			return ;
		}
		System.out.println("The list of vms is:");
		
		for (i = 0; i < vmlist.length; i ++) {
			System.out.println("The vm is "+vmlist[i]);
		}
		int vmid = this.use_first_vm ? vmlist[0].getId() : choose_vm(vmlist) ;
		
		if (list_vm_only) {
			System.out.println("Not connecting to vm "+vmid+" because -l was specified in the command line");
			return;
		}
		q.qvd_connect_to_vm(vmid);
		q.qvd_free();
	}
	private int choose_vm(Vm vmlist[]) throws IOException {
		String response;
		int i, responseint = -1;
		InputStreamReader inp = new InputStreamReader(System.in);
		BufferedReader br = new BufferedReader(inp);
		System.out.println("Choose vmid:");
		while (true) {
			response = br.readLine();
			responseint = Integer.valueOf(response).intValue();
			for (i=0; i < vmlist.length; i++) {
				if (vmlist[i].getId() == responseint) {
					return responseint;
				}
			}
			System.out.println("The vmid specified does not exist");
		}

	}
}

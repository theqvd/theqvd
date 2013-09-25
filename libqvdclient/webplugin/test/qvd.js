
function progress_callback(qvd,message)
{
    console.log("progress:"+qvd);
    console.log("progress2:"+message);
}

function select_vm_and_connect(vmid)
{
    console.log("Vmid pressed was " +vmid);
    var row = "vmlist-" + vmid;
    $("#select-vm").html("Connecting to VM "+vmid);
    $("#stopconnection").html('<div class="stoprow">Click here to stop connection</div>');
    $("#stopconnection").click(function() { $(this).off('click'); 
					    qvdembed.qvd_end_connection(); 
					    $(this).html('Ending connection'); 
					  });
    qvdembed.qvd_connect_to_vm(vmid);
}

function after_qvd_list_of_vm(qvd, vmlist)
{
    $("#vmlist").html("");
    $.each(vmlist, function(index, value)
    	   {
    	       var row = "vmlist-"+index;
	       var vmid=value["id"];
    	       var element = $("#vmlist").append("<div class=\"vmlistrow\" id=\""+row+"\"  >"+
    						 "id:" + vmid + ";" +
    						 "name:" + value["name"] + ";" +
    						 "state:" + value["state"] + ";" +
    						 "blocked:" + value["blocked"] + ";" +
    						 "</div>");
	       $("#"+row).click(function() { $(this).off('click'); select_vm_and_connect(vmid) });
    	   });

    if (vmlist.length > 0)
    {
	$("#select-vm").html("Please click on the vm you want to connect to");
    } else
    {
	$("#select-vm").html("No valid VM was found, revise parameters, are host username and pass corect? Error was:"+qvdembed.qvd_get_last_error());
    }
}


function unknown_cert_callback(qvd, cert_str, cert_data)
{
    var result = window.confirm("Unknown Cert:\n\n"+cert_str+"\nDo you trust this certificate?");
    return result;
}

function qvdinvoke(login, password, host, port)
{
    
    $("#vmlist").html("Obtaining list of VMs");
    qvdembed.qvd_init(host, port, login, password);
    qvdembed.qvd_set_unknown_cert_callback(unknown_cert_callback);
    qvdembed.qvd_set_progress_callback(progress_callback);
    qvdembed.qvd_list_of_vm(after_qvd_list_of_vm);
    
}

function loginaction()
{
    console.log("login_action");
    var placeholder = $("#placeholder");
    qvdembed = document.createElement('embed');
    qvdembed.setAttribute('id', 'myembed');
    qvdembed.setAttribute('type', 'application/theqvd');
    qvdembed.setAttribute('style', 'height: 0; width: 0;');
    placeholder.append(qvdembed);
    
    console.log(qvdembed);
    
    var version = qvdembed.qvd_get_version();
    console.log(version);
    $("#version").append(version);
    
    
    var versiontext = qvdembed.qvd_get_version_text();
    console.log(versiontext);
    $("#versiontext").append(versiontext);
    $("#connectionparams").hide();

    console.log("value" + $("#login").val());
    qvdinvoke($("#login").val(), $("#password").val(), $("#host").val(), 8443)
}
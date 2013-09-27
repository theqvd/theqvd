
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
					    qvd.qvd_end_connection(); 
					    $(this).html('Ending connection'); 
					  });
    // Set the display if you need it
    // qvd.qvd_set_display(":0");
    var result = qvdembed.qvd_connect_to_vm(vmid);
    if (!result)
    {
	window.alert("Error connecting to VM: " + qvd.qvd_get_last_error())
    }
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
	$("#select-vm").html("No valid VM was found, revise parameters, are host username and pass corect? Error was:"+qvd.qvd_get_last_error());
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
    qvd.qvd_init(host, port, login, password);
    qvd.qvd_set_unknown_cert_callback(unknown_cert_callback);
    qvd.qvd_set_progress_callback(progress_callback);
    qvd.qvd_list_of_vm(after_qvd_list_of_vm);
    
}

function myinit()
{
    console.log("myinit");
    qvd = document.getElementById("qvdobject");;
    if (!qvd.qvd_get_version())
	alert("Error loading qvd plugin");
    console.log(qvd);
}

function displayversion()
{
    var version = qvd.qvd_get_version();
    console.log(version);
    $("#version").append(version);
    
    
    var versiontext = qvd.qvd_get_version_text();
    console.log(versiontext);
    $("#versiontext").append(versiontext);

}

function loginaction()
{
    console.log("login_action");
    $("#connectionparams").hide();
    
    console.log("value" + $("#login").val());
    qvdinvoke($("#login").val(), $("#password").val(), $("#host").val(), 8443)
}
package QVD::Admin4::Utils;
use Exporter;

# base class of this(Arithmetic) module
@ISA = qw(Exporter);

# Exporting the add and subtract routine
@EXPORT = 
qw(select
update
add
delete 
relation     
property    
start_vm
stop_vm
block_vm
unblock_vm
block_host
unblock_host
diconnect_user 
add_user  
add_vm
add_host
add_di
add_osf
);

###############################
########### ACTIONS  ##########
###############################

### BASIC SQL QUERIES
 
sub select
{
    my ($DB,$table, $filters,$arguments) = @_;
    
    ( $DB->resultset($table)->search($filters)->all );
}

sub update
{  
    my ($object, $table, $filters,$arguments) = @_;  
    ( $object->update($arguments) ); 
}

sub add
{
    my ($DB, $table, $filters,$arguments) = @_;
     
   ( $DB->resultset($table)->create($arguments) ); 
}

sub delete 
{  
    my ($object, $table, $filters,$arguments) = @_;
    ( $object->delete );
}

### RELATIONS BETWEEN TABLES

sub relation     
{  
    my ($object, $table, $filters,$arguments) = @_;
    my $relation = delete $arguments->{'relation'} // die "No relation specified";
    ( $object->$relation );
}

### RETRIEVES THE VALUE OF AN SPECIFIC COLUMN

sub property    
{  
    my ($object, $table, $filters,$arguments) = @_;
    my $property = delete $arguments->{'property'} // die "No property specified";
    ( { $property => $_->$property } ); # FIXME: Retrieves an array of unblessed reference...
}

### COMPLEX (AT LEAST CONCEPTUALLY) TRANSACTIONS

sub start_vm
{ 
    my ($vm,$table,$filters,$arguments) = @_;

    $vm->vm_runtime->vm_state eq 'stopped' || 
	die "Current VM is not stopped: unable to start";

    $vm->vm_runtime->blocked  && 
	die "Current VM is blocked: unable to start";

    use QVD::L7R::LoadBalancer;
    my $host_id = QVD::L7R::LoadBalancer->new->get_free_host($vm) // 
	die "Not available host. Unable to start";

    $vm->vm_runtime->update({host_id => $host_id, vm_cmd => 'start'});	

    use QVD::DB::Simple;
    notify("qvd_cmd_for_vm_on_host$host_id"); ();
}

sub stop_vm
{		 
    my ($vm,$table,$filters,$arguments) = @_;

    my $host_id = $vm->vm_runtime->host_id //
	die "No host_id in non stopped VM...";

    $vm->vm_runtime->vm_state eq 'stopped' &&
	die "Current VM is stopped: unable to stop";
		 
    $vm->vm_runtime->update({vm_cmd => 'stop'});	

    use QVD::DB::Simple;
    notify("qvd_cmd_for_vm_on_host$host_id"); ();
}

sub block_vm
{
    my ($vm,$table,$filters,$arguments) = @_;

    $vm->vm_runtime->blocked  && 
	die "Current VM is blocked: unable to block";
				       
    $vm->vm_runtime->update({blocked => 1}); ();
}

sub  unblock_vm
{
    my ($vm,$table,$filters,$arguments) = @_;

    $vm->vm_runtime->blocked || 
	die "Current VM is not blocked: unable to unblock.";

    $vm->vm_runtime->update({blocked => 0}); ();
}

sub block_host
{
    my ($host,$table,$filters,$arguments) = @_;

    $host->runtime->blocked && 
	die "Current Host is blocked: unable to block.";

    $host->runtime->update({blocked => 1}); ();
}

sub unblock_host
{
    my ($host,$table,$filters,$arguments) = @_;

    $host->runtime->blocked  || 
	die "Current Host is not blocked: unable to unblock.";
			 
    $host->runtime->update({blocked => 0}); ();
}

sub diconnect_user 
{ 
    my ($vm,$table,$filters,$arguments) = @_;

    $vm->vm_runtime->user_state =~ /^connect(ed|ing)$/ ||
	die "Current VM's user is not connected: unable to disconnect.";

    $vm->vm_runtime->update({user_cmd => 'abort'}); ();
}

sub add_user  
{ 
    my ($DB,$table,$filters,$arguments) = @_; ();
}

sub add_vm
{
    my ($DB,$table,$filters,$arguments) = @_;
}

sub add_host
{
    my ($DB,$table,$filters,$arguments) = @_;
}


sub add_di
{
    my ($DB,$table,$filters,$arguments) = @_;
}

sub add_osf
{
    my ($DB,$table,$filters,$arguments) = @_;
}


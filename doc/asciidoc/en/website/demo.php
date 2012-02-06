<?php
if(!empty($_POST)){
if(!empty($_REQUEST['mail'])&&!empty($_REQUEST['last_name'])){
  //add to the db
  global $wpdb;
  if($wpdb->get_row("SELECT email1 FROM qvd_trial_contacts WHERE email1 = '" . $_REQUEST['mail'] . "'", 'ARRAY_A')) {
  $error = 'The email address '. $_REQUEST['mail'].' has already been registered!';
  }
  else
  {
     $wpdb->insert( 'qvd_trial_contacts', array( 'salutation' => $_REQUEST['salutation'], 'first_name' => $_REQUEST['first_name'], 'last_name' => $_REQUEST['last_name'], 'email1' => $_REQUEST['mail'], 'title' => $_REQUEST['title'], 'account_name' => $_REQUEST['account_name'], 'department' => $_REQUEST['department'], 'phone_work' => $_REQUEST['phone_work'], 'website' => $_REQUEST['website']  ) );
     echo '<h2>Success!</h2>
<p>Your Demo request has been submitted. Please wait for a few moments while we process your request, and then check your email. Your demo account will be automatically provisioned within our hosted environment and in the next 10 minutes, you should be able to login using a QVD GUI Client.</p>
<p>While you\'re waiting, why not head over to our <a href="/product/download">download page</a> and start downloading the Client application most suited for your platform. Or if you want to know more, you might want to <a href="/support/documentation">read some documentation</a>.</p>
<p>Remember that if you\'re impressed with what you get in our demo, we can host an environment for you in a similar way. Consider signing up for our Cloud Edition.</p>';
  }
}
else {
$error="Email Address and Last Name are required!."; 
}
}
if(empty($_POST)||!empty($error)) {
if(!empty($error)){
echo "<div style='color: red; border: 1px solid red; padding: 4px;'><strong>Error:</strong>". $error ."</div>";
}
else {
?>
<h2>About the QVD Demo</h2>
<p>The QVD Demo is a hosted environment managed by the QVD Team, and is an example of how QVD Cloud Edition can be used to easily manage and provision remote desktop access for your users. In order to use the demo, you will first need to register, so that our automated provisioning system can create an account for you and build a virtual desktop that you can login to. Once you have provided these details, it will take about 10 minutes for our provisioning system to email you your account details and to complete the configuration process. During this time, you should download the appropriate client for your platform and get ready to connect. Once you have received the email, you can use the connection details provided to connect to your virtual desktop across the Internet. If you have any trouble connecting to the demonstration server, please let us know and we will do our best to help you.</p>

<h2>Register for the QVD Demo</h2>
<?php } ?>
<form name="registerform" id="registerform" action="/product/demo" method="post">
        <p>
                <label>Salutation<br />
<SELECT name="salutation" id="salutation" tabindex='2'> 
<option value="Mr">Mr</option>
<option value="Mrs">Mrs</option>
<option value="Ms">Ms</option>
<option value="Dr">Dr</option>
<option value="Prof">Prof</option>
</SELECT></label>
        </p>
        <p>
                <label>First Name<br />
                <input type="text" name="first_name" id="first_name" class="input" value="<?php
 echo $_REQUEST['first_name']; ?>" size="20" tabindex="10" /></label>
        </p>
<p>
                <label>Surname (Required)<br />
                <input type="text" name="last_name" id="last_name" class="input" value="<?php
 echo $_REQUEST['last_name']; ?>" size="20" tabindex="15" /></label>
        </p>
        <p>
                <label>E-mail (Required)<br />
                <input type="text" name="mail" id="mail" class="input" value="<?php
 echo $_REQUEST['mail']; ?>" size="25" tabindex="20" /></label>
        </p>
        <p>
                <label>Company<br />
                <input type="text" name="account_name" id="account_name" class="input" value="<?php
 echo $_REQUEST['account_name']; ?>" size="25" tabindex="20" /></label>
        </p>
        <p>
                <label>Department<br />
                <input type="text" name="department" id="department" class="input" value="<?php
 echo $_REQUEST['department']; ?>" size="25" tabindex="30" /></label>
        </p>
        <p>
                <label>Job Title<br />
                <input type="text" name="title" id="title" class="input" value="<?php
 echo $_REQUEST['title']; ?>" size="25" tabindex="40" /></label>
        </p>
        <p>
                <label>Phone Number<br />
                <input type="text" name="phone_work" id="phone_work" class="input" value="<?php
 echo $_REQUEST['phone_work']; ?>" size="25" tabindex="50" /></label>
        </p>
        <p>
                <label>Website<br />
                <input type="text" name="website" id="website" class="input" value="<?php
 echo $_REQUEST['website']; ?>" size="25" tabindex="60" /></label>
        </p>
        <p>By clicking on the Register button below, you agree to the
        contract set out in our <a
        href="/product/demo/terms-of-service">Terms of Service</a></p>
        <p id="reg_passmail">When you submit this form, the Demo instructions will be e-mailed to you. It is likely that it will take about 10 minutes for us to provision your desktop. Please be patient.</p>
        <br class="clear" />
        <p class="submit"><input type="submit" name="register" id="register" class="button-primary" value="Register" tabindex="100" /></p>
</form>
<?php
}
?>

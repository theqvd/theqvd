<?php

function validate_form($vars, &$error= null){
 if(empty($vars['last_name'])){
   $error['last_name']="Last name is required!";
 }
 if(empty($vars['mail'])){
   $error['mail']="Email address is required!";
 }

 # formatting of fields (e.g. date, mail)
 
 if(!empty($vars['mail']) && ! preg_match("/^[^@]*@[^@]*\.[^@]*$/", $vars['mail']) ){
   $error['mail']="Email address is badly formatted!";
 }
 $phone=preg_replace('/\s+/','',$vars['phone_work']);
 if(!empty($vars['phone_work']) && ! preg_match("/^\+\d{1,3}[\s.()-]*(\d[\s.()-]*){6,20}(x\d*)?$/",$phone)){
   $error['phone_work']="Telephone number (".$phone.") is badly formatted! Try something like +34 91 766 23 57";
 }

 return null;
}

if(!empty($_POST)){
  validate_form($_POST,$error);
  if(empty($error)){ 
  //add to the db
  global $wpdb;
  if($wpdb->get_row("SELECT email1 FROM qvd_trial_contacts WHERE email1 = '" . $_REQUEST['mail'] . "'", 'ARRAY_A')) {
     $error['mail_registered'] = 'The email address '. $_REQUEST['mail'].' has already been registered!';
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
}
if(empty($_POST)||!empty($error)) {
if(!empty($error)){
$msg=implode('<br/>',$error);
echo "<div style='color: red; border: 1px solid red; padding: 4px;'><strong>The following errors have been detected:</strong><br/>". $msg ."</div>";
}
else {
?>
<h2>About the QVD Demo</h2>
<p>The QVD Demo is a hosted environment managed by the QVD Team, and is an example of how QVD Cloud Edition can be used to easily manage and provision remote desktop access for your users. In order to use the demo, you will first need to register, so that our automated provisioning system can create an account for you and build a virtual desktop that you can login to. Once you have provided these details, it will take about 10 minutes for our provisioning system to email you your account details and to complete the configuration process. During this time, you should download the appropriate client for your platform and get ready to connect. Once you have received the email, you can use the connection details provided to connect to your virtual desktop across the Internet. If you have any trouble connecting to the demonstration server, please let us know and we will do our best to help you.</p>

<h2>Register for the QVD Demo</h2>
<?php } ?>
<form name="registerform" id="registerform" action="/product/demo" method="post">
        <p>
                <label class='niceform'>Salutation</label>
<SELECT name="salutation" id="salutation" tabindex='2'> 
<option value="Mr">Mr</option>
<option value="Mrs">Mrs</option>
<option value="Ms">Ms</option>
<option value="Dr">Dr</option>
<option value="Prof">Prof</option>
</SELECT>
       </p>
        <p>
                <label class='niceform'>First Name</label>
                <input type="text" name="first_name" id="first_name" class="input" value="<?php
 echo $_REQUEST['first_name']; ?>" size="25" tabindex="10" />
        <br/>
        </p>
        <p>
                <label class='niceform'>Surname (Required)</label>
                <input type="text" name="last_name" id="last_name" class="input" value="<?php
 echo $_REQUEST['last_name']; ?>" size="25" tabindex="15" />
        <br/> 
        </p>
        <p>
                <label class='niceform'>E-mail (Required)</label>
                <input type="text" name="mail" id="mail" class="input" value="<?php
 echo $_REQUEST['mail']; ?>" size="25" tabindex="20" />
<br/>
        </p>
        <p>
                <label class='niceform'>Company</label>
                <input type="text" name="account_name" id="account_name" class="input" value="<?php
 echo $_REQUEST['account_name']; ?>" size="25" tabindex="20" />
<br/>        
</p>
        <p>
                <label class='niceform'>Department</label>
                <input type="text" name="department" id="department" class="input" value="<?php
 echo $_REQUEST['department']; ?>" size="25" tabindex="30" />
<br/>        
</p>
        <p>
                <label class='niceform'>Job Title</label>
                <input type="text" name="title" id="title" class="input" value="<?php
 echo $_REQUEST['title']; ?>" size="25" tabindex="40" />
<br/>        
</p>
        <p>
                <label class='niceform'>Phone Number</label>
                <input type="text" name="phone_work" id="phone_work" class="input" value="<?php
 echo $_REQUEST['phone_work']; ?>" size="25" tabindex="50" />
<br/>        
</p>
        <p>
                <label class='niceform'>Website</label>
                <input type="text" name="website" id="website" class="input" value="<?php
 echo $_REQUEST['website']; ?>" size="25" tabindex="60" />
<br/>        
</p>
<p>
    <script type="text/javascript"
       src="http://www.google.com/recaptcha/api/challenge?k=6LcFI8oSAAAAAOCxXMRBUHChw9gHp12yhOkOJZII ">
    </script>
    <noscript>
       <iframe src="http://www.google.com/recaptcha/api/noscript?k=6LcFI8oSAAAAAOCxXMRBUHChw9gHp12yhOkOJZII "
           height="300" width="500" frameborder="0"></iframe><br>
       <textarea name="recaptcha_challenge_field" rows="3" cols="40">
       </textarea>
       <input type="hidden" name="recaptcha_response_field"
           value="manual_challenge">
    </noscript>

</p>
        <p>By clicking on the Register button below, you agree to the contract set out in our <a href="/product/demo/terms-of-service">Terms of Service</a></p>
        <p id="reg_passmail">When you submit this form, the Demo instructions will be e-mailed to you. It is likely that it will take about 10 minutes for us to provision your desktop. Please be patient.</p>
        <br class="clear" />
        <p class="submit"><input type="submit" name="register" id="register" class="button-primary" value="Register" tabindex="100" /></p>
</form>
<?php
}
?>


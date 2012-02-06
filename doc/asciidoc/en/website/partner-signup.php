<?php

function validate_form($vars, &$error= null){
 # check that the email address is not taken or the company does not already exist in the db (not required)

 # check for required fields
 if(empty($vars['first_name'])){
   $error['first_name']="First name is required!";
 }
 if(empty($vars['last_name'])){
   $error['last_name']="Last name is required!";
 }
 if(empty($vars['mail'])){
   $error['mail']="Email address is required!";
 }
 if(empty($vars['phone_work'])){
   $error['phone_work']="Phone number is required!";
 }
 if(empty($vars['companyname'])){
   $error['companyname']="Company name is required!";
 }

 # formatting of fields (e.g. date, mail)
 
 if(!empty($vars['mail']) && ! preg_match("/^[^@]*@[^@]*\.[^@]*$/", $vars['mail']) ){
   $error['mail']="Email address is badly formatted!";
 }

 if(!empty($vars['date_closed'])&& !strtotime( $vars['date_closed'] )){
   $error['date_closed']="Date is badly formatted!";
 }


 return null;
}

if(!empty($_POST)){
 validate_form($_REQUEST,$error);
 
 if(empty($error)){
  //add to the db
  global $wpdb;
  $wpdb->insert( 'qvd_partner_contacts', array( 'salutation' => $_REQUEST['salutation'], 'first_name' => $_REQUEST['first_name'], 'last_name' => $_REQUEST['last_name'], 'email1' => $_REQUEST['mail'], 'title' => $_REQUEST['title'], 'department' => $_REQUEST['department'], 'phone_work' => $_REQUEST['phone_work'], 'name' => $_REQUEST['company_name'], 'annual_revenue' => $_REQUEST['annual_revenue'], 'website' => $_REQUEST['website'], 'company_description' => $_REQUEST['company_description'], 'employees' => $_REQUEST['employees'], 'billing_address_street' => $_REQUEST['billing_address_street'], 'billing_address_city' => $_REQUEST['billing_address_city'], 'billing_address_state' => $_REQUEST['billing_address_state'], 'billing_address_postalcode' => $_REQUEST['billing_address_postalcode'], 'billing_address_country' => $_REQUEST['billing_address_country'], 'account_type' => $_REQUEST['account_type'], 'partner_area_c' => $_REQUEST['partner_area_c'], 'currency_name' => $_REQUEST['currency_name'], 'amount' => $_REQUEST['amount'], 'date_closed' => $_REQUEST['date_closed'], 'opportunity_description' => $_REQUEST['opportunity_description']  ) );
  echo '<h2>Success!</h2>
<p>Your partnership request has been submitted. Please wait for a few moments while we process your request, and then check your email. The QVD Channel Manager will contact you shortly with regard to your request.</p>';  
 }
 else {

 }
}

if(empty($_POST)||!empty($error)) {
if(!empty($error)){
$msg=implode('<br/>',$error);
echo "<div style='color: red; border: 1px solid red; padding: 4px;'><strong>The following errors have been detected:</strong><br/>". $msg ."</div>";
}
else {
?>
<p>If you are thinking of becoming a partner and haven't already done so, please look over our <a href="/partner">Partner</a> page to get a bigger picture of how a partnership might benefit you, and to understand our partnership options.</p>
<?php } ?>
<form name="registerform" id="registerform" action="/partner/signup" method="post">

<h2>Personal Details</h2>
<p>The following details will provide us with the means to contact you and will also be used to provision your access to partner resources.</p>
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
<?php
if(!empty($error['first_name'])){
echo '<span style="color: red;">'.$error['first_name'].'<span><br/>';
}
?>
                <label>First Name (Required)<br />
                <input type="text" name="first_name" id="first_name" class="input" value="<?php
 echo $_REQUEST['first_name']; ?>" size="20" tabindex="10" /></label>
        </p>
<p>
<?php
if(!empty($error['last_name'])){
echo '<span style="color: red;">'.$error['last_name'].'<span><br/>';
}
?>
                <label>Surname (Required)<br />
                <input type="text" name="last_name" id="last_name" class="input" value="<?php
 echo $_REQUEST['last_name']; ?>" size="20" tabindex="15" /></label>
        </p>
        <p>
<?php
if(!empty($error['mail'])){
echo '<span style="color: red;">'.$error['mail'].'<span><br/>';
}
?>
                <label>E-mail (Required)<br />
                <input type="text" name="mail" id="mail" class="input" value="<?php
 echo $_REQUEST['mail']; ?>" size="25" tabindex="20" /></label>
        </p>
        <p>
                <label>Job Title<br />
                <input type="text" name="title" id="title" class="input" value="<?php
 echo $_REQUEST['title']; ?>" size="25" tabindex="25" /></label>
        </p>
        <p>
                <label>Department<br />
                <input type="text" name="department" id="department" class="input" value="<?php
 echo $_REQUEST['department']; ?>" size="25" tabindex="30" /></label>
        </p>
        <p>
<?php
if(!empty($error['phone_work'])){
echo '<span style="color: red;">'.$error['phone_work'].'<span><br/>';
}
?>
                <label>Phone Number (Required)<br />
                <input type="text" name="phone_work" id="phone_work" class="input" value="<?php
 echo $_REQUEST['phone_work']; ?>" size="25" tabindex="35" /></label>
        </p>
        

<h2>Company Details</h2>
<p>We use this information to define the most likely type of partnership with you and to prepare contracts.</p>

        <p>
<?php
if(!empty($error['name'])){
echo '<span style="color: red;">'.$error['name'].'<span><br/>';
}
?>
                <label>Company Name (Required)<br />
                <input type="text" name="companyname" id="companyname" class="input" value="<?php
 echo $_REQUEST['companyname']; ?>" size="25" tabindex="40" /></label>
        </p>
        <p>
                <label>Estimated Annual Revenue<br />
                <input type="text" name="annual_revenue" id="annual_revenue" class="input" value="<?php
 echo $_REQUEST['annual_revenue']; ?>" size="25" tabindex="45" /></label>
        </p>

<p>
                <label>Website<br />
                <input type="text" name="website" id="website" class="input" value="<?php
 echo $_REQUEST['website']; ?>" size="25" tabindex="50" /></label>
        </p>

<p>
                <label>Description of your company<br />
<textarea cols="40" rows="3" name="company_description" id="company_description" class="input" tabindex="55">
<?php
 echo $_REQUEST['company_description']; ?>
</textarea>
</label>
        </p>
<p>
                <label>Number of Employees<br />
                <input type="text" name="employees" id="employees" class="input" value="<?php
 echo $_REQUEST['employees']; ?>" size="25" tabindex="60" /></label>
        </p>


<p>
                <label>Company Street Address<br />
                <input type="text" name="billing_address_street" id="billing_address_street" class="input" value="<?php
 echo $_REQUEST['billing_address_street']; ?>" size="25" tabindex="65" /></label>
        </p>
<p>
                <label>City<br />
                <input type="text" name="billing_address_city" id="billing_address_city" class="input" value="<?php
 echo $_REQUEST['billing_address_city']; ?>" size="25" tabindex="70" /></label>
        </p>

<p>
                <label>State<br />
                <input type="text" name="billing_address_state" id="billing_address_state" class="input" value="<?php
 echo $_REQUEST['billing_address_state']; ?>" size="25" tabindex="75" /></label>
        </p>

<p>
                <label>Postal Code<br />
                <input type="text" name="billing_address_postalcode" id="billing_address_postalcode" class="input" value="<?php
 echo $_REQUEST['billing_address_postalcode']; ?>" size="10" tabindex="80" /></label>
        </p>

<p>
                <label>Country<br />
                <input type="text" name="billing_address_country" id="billing_address_country" class="input" value="<?php
 echo $_REQUEST['billing_address_country']; ?>" size="25" tabindex="85" /></label>
        </p>


<h2>Partnership Information</h2>
<p>The following options will help us to determine the type of partnership that you are expecting to engage in.</p>

<label>Partnership Type<br />
<SELECT name="account_type" id="account_type" tabindex='90'> 
<option value="Reseller">Reseller</option>
<option value="Integrator">Integrator and Reseller</option>
</SELECT></label>

<p>
                <label>Area of Operation (usually the country that you expect to do business in)<br />
                <input type="text" name="partner_area_c" id="partner_area_c" class="input" value="<?php
 echo $_REQUEST['partner_area_c']; ?>" size="25" tabindex="95" /></label>
        </p>

<h2>Opportunity Information</h2>
<p>If you already have an opportunity that you are pursuing, we appreciate a few details so that we can help to expediate the partnership process and get you started. It also helps us to protect your interests from being poached by an existing partner.</p>

<p>
<label>Currency<br />
<SELECT name="currency_name" id="currency_name" tabindex='100'> 
<option value="EUR">Euros</option>
<option value="USD">US Dollars</option>
</SELECT></label>
</p>

<p>
                <label>Expected value of potential deal<br />
                <input type="text" name="amount" id="amount" class="input" value="<?php
 echo $_REQUEST['amount']; ?>" size="10" tabindex="105" /></label>
        </p>

<p>
<?php
if(!empty($error['date_closed'])){
echo '<span style="color: red;">'.$error['date_closed'].'<span><br/>';
}
?>
                <label>Expected Close Date for Partnership<br />
                <input type="text" name="date_closed" id="date_closed" class="input" value="<?php
 if(isset($_REQUEST['date_closed'])){echo $_REQUEST['date_closed'];} else{ echo 'yyyy-mm-dd';} ?>" size="25" tabindex="110" /></label>
        </p>


<p>
                <label>Description of potential opportunity<br />
<textarea cols="40" rows="3" name="opportunity_description" id="opportunity_description" class="input" tabindex="115">
<?php
 echo $_REQUEST['opportunity_description']; ?>
</textarea>
</label>
        </p>

        <br class="clear" />
        <p class="submit"><input type="submit" name="register" id="register" class="button-primary" value="Register" tabindex="100" /></p>
</form>
<?php
}
?>
<?php
#first check if the user is logged in or provide a login/register page
if (!is_user_logged_in()){
?>

<div id="login"><p>You need to login to purchase licenses. If you have not already got an account with us, please go ahead and <a href="<?php bloginfo('url') ?>/register.php">register</a>. Note that if you have registered to try out the demo, you will already have an account.</p>
</div>

<form name="loginform" id="loginform" action="<?php bloginfo('url') ?>/wp-login.php" method="post" style="left: 0px; position: static; ">
        <p>
                <label>Username<br>
                <input type="text" name="log" id="user_login" class="input" value="" size="20" tabindex="10"></label>
        </p>
        <p>
                <label>Password<br>
                <input type="password" name="pwd" id="user_pass" class="input" value="" size="20" tabindex="20"></label>
        </p>
        <p class="forgetmenot"><label><input name="rememberme" type="checkbox" id="rememberme" value="forever" tabindex="90"> Remember Me</label></p>
        <p class="submit">
                <input type="submit" name="wp-submit" id="wp-submit" class="button-primary" value="Log In" tabindex="100">
                <input type="hidden" name="redirect_to" value="<?php echo $_SERVER['REQUEST_URI']; ?>">
                <input type="hidden" name="testcookie" value="1">
        </p>
</form>
                        <p><a href="<?php bloginfo('url') ?>/register.php">Register</a></p>
<?php
}
else {

# check whether we have appropriate billing information for the customer in our session

  # if not, we need to get this information to store in sugarcrm



# user is logged in. present shopping options
    global $current_user;
    get_currentuserinfo();
    $profile = array(
                'appId' => "Qindel",
                'userId' => $current_user->user_login,
                'profile' => array(
                        'email' => $current_user->user_email,
                        'billingPerson' => array(
                                'name' => $_SESSION['name'],
                                'companyName' => $_SESSION['company_name'],
                                'street' => $_SESSION['street'],
                                'city' => $_SESSION['city'],
                                'countryCode' => $_SESSION['country_code'],
                                'postalCode' => $_SESSION['post_code'],
                                'phone' => $_SESSION['phone']
                        )
                )
    );
    $message = json_encode($profile);
    $message = base64_encode($message);
    $timestamp = time();
    $hmac = hash_hmac('sha1', "$message $timestamp", "nVYHC4CHLjmA");
    echo "<script>var ecwid_sso_profile='$message $hmac $timestamp'</script>";
?>
<div class='ecwid-Product'><form>
<div style='text-align: center; padding-bottom: 10px;'><script type="text/javascript" src="http://app.ecwid.com/script.js?738134" charset="utf-8"></script><script type="text/javascript">xProductThumbnail('productid=6931186');</script></div>
<div class='ecwid-productBrowser-head' style='text-align: center; padding-bottom: 15px; font: normal 20px tahoma, geneva, verdana, sans-serif'>QVD Commercial Edition License</div>
<div class='ecwid-productBrowser-price' style='text-align: center; padding-bottom: 15px' id='ecwid-price-6931186'><span style='font-family:trebuchet MS'>&euro;</span>120.00</div>
<table align='center' border='0'><tr><td align='left' class='ecwid'></td></tr></table><div style='text-align: center'><script type="text/javascript" src="http://app.ecwid.com/script.js?738134" charset="utf-8"></script><script type="text/javascript">xAddToBag('productid=6931186');</script></div>
</form></div>

<?php
}
?>

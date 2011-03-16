<?php

require( '../wp-load.php' );

function import_html_files_cat($category) {
    
    // Create parent page
    $my_post_cat = array();
    $my_post_cat['post_title']  = $category;
    $my_post_cat['post_type']   = 'page';
    $my_post_cat['post_status'] = 'publish';
    $my_post_cat['post_parent'] = 300; // default for our 'technical documentation' category
    $my_post_cat['post_author'] = 2; // default for our 'doc' user
    $category_id = wp_insert_post($my_post_cat);
    
    global $wpdb;
    
    $wpdb->update( 'wp_icl_translations', array( 'language_code' => 'en'), array( 'element_id' => $category_id ), array( '%s' ), array( '%d' ) );
    
    $rootdir = './html/en/'.$category;
    $dir_content = scandir($rootdir);

    foreach($dir_content as $key => $val) {
	set_time_limit(30);
	$path = $rootdir.'/'.$val;
	
	if(is_file($path) && is_readable($path)) {	
	    $contents = @fopen($path);
	    if (empty($contents)) $contents = @file_get_contents($path);
	    if (empty($contents)) wp_die("Empty");

	    else $encoded = $contents;
	    
	    $doc = new DOMDocument();
	    $doc->strictErrorChecking = false;
	    $doc->preserveWhiteSpace = false;  
	    $doc->formatOutput = false;
	    @$doc->loadHTML($encoded);
	    $xml = @simplexml_import_dom($doc);
			
	    $my_post = array();	
	    
	    $my_post['post_title']   = $xml->xpath('//head/title');
	    $my_post['post_title']   = $my_post['post_title'][0];
	    $my_post['post_content'] = $xml->xpath("id('content')");
	    $my_post['post_content'] = $my_post['post_content'][0]->asXML();
	    
	    $footer = $xml->xpath("id('footer-text')");
	    $footer = $footer[0]->asXML();
	    
	    $my_post['post_content'] = $my_post['post_content'].'<div class="version">'.$footer."</div>";
	    $my_post['post_content'] = str_replace('&#13;', ' ', $my_post['post_content']); 
	    $my_post['post_type']    = 'page';
	    $my_post['post_status']  = 'publish';
	    $my_post['post_parent']  = $category_id; // default for our 'documentación técnica' category
	    $my_post['post_author']  = 2; // default for our 'doc' user
	        	    
	    $my_post_id = wp_insert_post($my_post);
	    
	    global $wpdb;
    	    
	    $wpdb->update( 'wp_icl_translations', array( 'language_code' => 'en'), array( 'element_id' => $my_post_id ), array( '%s' ), array( '%d' ) );
	}
    }
    
    
}

function import_html_files() {

    global $wpdb;
    
    $ids[] = $wpdb->get_results('select ID from ' . $wpdb->posts . ' where (post_author = 2)');
    
    // Delete all the published doc pages
    
    foreach ($ids[0] as $page) {
	wp_delete_post($page->ID, 1);
    }
    
    
    import_html_files_cat("installation");
    import_html_files_cat("licenses");
    import_html_files_cat("operations");
    import_html_files_cat("overview");
    
    
wp_die ('Documentation generated successfully.');
 
}

import_html_files();

?>

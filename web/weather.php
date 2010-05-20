<?php
// We don't need any stupid error messages
ob_start( );

// Load the Weather data
$xml = simplexml_load_file( 'http://www.google.com/ig/api?weather=Las+Vegas,+NV' );

// current weather
$value = array( );
$value[] = strtolower( $xml->weather->current_conditions->condition['data'] );

// clear everything outputted until now & output our data
ob_end_clean( );
echo json_encode( $value );

?>

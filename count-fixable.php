<?php
$json = json_decode( file_get_contents( 'php://stdin' ), true );

$fixable = 0;

foreach ( $json['files'] as $path => $file ) {
	foreach ( $file['messages'] as $msg ) {
		if ( $msg['fixable'] ) {
			$fixable++;
		}
	}
}

echo $fixable;

//var_dump( json_encode( $json, JSON_PRETTY_PRINT ) );

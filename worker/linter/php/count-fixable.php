<?php
require '/worker/get-diff.php';
$json = json_decode( file_get_contents( 'php://stdin' ), true );

$fixable = 0;

if ( empty( $json ) ) {
	echo $fixable;
	exit;
}

foreach ( $json['files'] as $path => $file ) {
	if ( ! isset( $changed[ $path ] ) ) {
		continue;
	}
	foreach ( $file['messages'] as $msg ) {
		if ( ! isset( $changed[ $path ][ $msg['line'] ] ) ) {
			continue;
		}
		if ( $msg['fixable'] ) {
			$fixable++;
		}
	}
}

echo $fixable;

//var_dump( json_encode( $json, JSON_PRETTY_PRINT ) );

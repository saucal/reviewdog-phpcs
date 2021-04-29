<?php
require '/worker/get-diff.php';
$json = json_decode( file_get_contents( 'php://stdin' ), true );

$fixable = 0;

foreach ( $json as $i => $file ) {
	$path = $file['filePath'];
	if ( ! isset( $changed[ $path ] ) ) {
		continue;
	}
	foreach ( $file['messages'] as $msg ) {
		if ( ! isset( $changed[ $path ][ $msg['line'] ] ) ) {
			continue;
		}
		if ( ! empty( $msg['fix'] ) ) {
			$fixable++;
		}
	}
}

echo $fixable;

//var_dump( json_encode( $json, JSON_PRETTY_PRINT ) );

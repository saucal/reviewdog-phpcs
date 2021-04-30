<?php
$unfixables = json_decode( file_get_contents( getenv( 'STYLELINT_UNFIXABLE_JSON' ) ) );
$all = json_decode( file_get_contents( getenv( 'STYLELINT_ALL_JSON' ) ) );

$unfixables_list = array();

foreach ( $unfixables as $file ) {
	foreach ( $file->warnings as $warn ) {
		$key = md5( json_encode( $warn ) );
		$unfixables_list[ $key ] = true;
	}
}

foreach ( $all as $file ) {
	foreach ( $file->warnings as $warn ) {
		$key = md5( json_encode( $warn ) );
		if ( isset( $unfixables_list[ $key ] ) ) {
			$warn->fixable = false;
		} else {
			$warn->fixable = true;
		}
	}
}

echo json_encode( $all, JSON_UNESCAPED_SLASHES );

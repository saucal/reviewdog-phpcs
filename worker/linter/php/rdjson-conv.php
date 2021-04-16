<?php
$json = json_decode( file_get_contents( 'php://stdin' ), true );

foreach ( $json['files'] as $path => $file ) {
	foreach ( $file['messages'] as $msg ) {
		if ( $msg['fixable'] ) {
			continue;
		}
		$row = array(
			'message'  => '`' . $msg['source'] . '`<br>' . $msg['message'],
			'location' => array(
				'path'  => $path,
				'range' => array(
					'start' => array(
						'line'   => $msg['line'],
						'column' => $msg['column'],
					),
				),
			),
			'severity' => $msg['type'],
		);
		echo json_encode( $row, JSON_UNESCAPED_SLASHES ) . "\n";
	}
}

//var_dump( json_encode( $json, JSON_PRETTY_PRINT ) );

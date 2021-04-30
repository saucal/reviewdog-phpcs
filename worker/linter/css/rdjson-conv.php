<?php
$json = json_decode( file_get_contents( 'php://stdin' ), true );

foreach ( $json as $i => $file ) {
	$path = $file['source'];
	foreach ( $file['warnings'] as $msg ) {
		if ( ! empty( $msg['fixable'] ) ) {
			continue;
		}
		$severity = strtoupper( $msg['severity'] );
		$row = array(
			'message'  => '`' . $msg['rule'] . '`<br>' . $msg['text'],
			'location' => array(
				'path'  => $path,
				'range' => array(
					'start' => array(
						'line'   => $msg['line'],
						'column' => $msg['column'],
					),
				),
			),
			'severity' => $severity,
		);
		echo json_encode( $row, JSON_UNESCAPED_SLASHES ) . "\n";
	}
}

//var_dump( json_encode( $json, JSON_PRETTY_PRINT ) );

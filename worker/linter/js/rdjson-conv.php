<?php
$json = json_decode( file_get_contents( 'php://stdin' ), true );

foreach ( $json as $i => $file ) {
	$path = $file['filePath'];
	foreach ( $file['messages'] as $msg ) {
		if ( ! empty( $msg['fix'] ) ) {
			continue;
		}
		$severity = false;
		switch ( (int) $msg['severity'] ) {
			case 2:
				$severity = 'ERROR';
				break;
			case 1:
				$severity = 'WARNING';
				break;
			case 0:
				continue 2;
		}
		$row = array(
			'message'  => '`' . $msg['ruleId'] . '`<br>' . $msg['message'],
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

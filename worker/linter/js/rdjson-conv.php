<?php
$out = array( 'diagnostics' => array() );
$json = json_decode( file_get_contents( 'php://stdin' ), true );

if( empty( $json ) ) {
	echo json_encode( $out, JSON_UNESCAPED_SLASHES ) . "\n";
	exit;
}

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
		$out['diagnostics'][] = $row;
	}
}
echo json_encode( $out, JSON_UNESCAPED_SLASHES ) . "\n";

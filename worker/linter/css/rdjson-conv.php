<?php
$out = array( 'diagnostics' => array() );
$json = json_decode( file_get_contents( 'php://stdin' ), true );

if( empty( $json ) ) {
	echo json_encode( $out, JSON_UNESCAPED_SLASHES ) . "\n";
	exit;
}

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
		$out['diagnostics'][] = $row;
	}
}
echo json_encode( $out, JSON_UNESCAPED_SLASHES ) . "\n";

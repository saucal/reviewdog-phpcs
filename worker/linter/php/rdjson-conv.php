<?php
$out = array( 'diagnostics' => array() );
$json = json_decode( file_get_contents( 'php://stdin' ), true );

if( empty( $json ) ) {
	echo json_encode( $out, JSON_UNESCAPED_SLASHES ) . "\n";
	exit;
}

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
		$out['diagnostics'][] = $row;
	}
}
echo json_encode( $out, JSON_UNESCAPED_SLASHES ) . "\n";

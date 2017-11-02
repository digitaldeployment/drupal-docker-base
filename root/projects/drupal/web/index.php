<?php

// Test stdout.
$stdout = fopen('php://stdout', 'w');
fwrite($stdout, "This is php://stdout!\n");

// Test stderr.
$stderr = fopen('php://stderr', 'w');
fwrite($stderr, "This is php://stderr!\n");

// Test error logging.
error_log('This is error_log()!');
trigger_error('This is trigger_error()', E_USER_WARNING);

// Serve PHP info.
phpinfo();

<?php
$options['r'] = '/var/drupal/www';
$command_specific['site-install']['db-url'] = empty($_ENV['CIRCLECI'])
  ? 'mysql://root@db/drupal'
  : 'mysql://root@127.0.0.1/circle_test';

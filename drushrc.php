<?php
$options['r'] = '/projects/drupal/web';
$command_specific['site-install']['db-url'] = empty($_SERVER['CIRCLECI'])
  ? 'mysql://root@db/drupal'
  : 'mysql://root@127.0.0.1/circle_test';

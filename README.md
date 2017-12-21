# drupal-docker-base

[![CircleCI](https://circleci.com/gh/digitaldeployment/drupal-docker-base.svg?style=svg)](https://circleci.com/gh/digitaldeployment/drupal-docker-base)

[Docker Hub](https://hub.docker.com/r/digdep/drupal-base/)

This is a base image for running Drupal 8 in development. It does not come with Drupal itself, but it does come with a properly configured NGINX (stable), PHP-FPM (7.1), Composer, Drush, Terminus, BusyBox sendmail (so you can set the `SMTPHOST` env variable to e.g. a MailHog container) dependencies for Cypress, and dependencies for CircleCI 2.0.

See `docker-compose.example.yml` for how to use.

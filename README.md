# drupal-docker-base

[![CircleCI](https://circleci.com/gh/digitaldeployment/drupal-docker-base.svg?style=svg)](https://circleci.com/gh/digitaldeployment/drupal-docker-base)

[Docker Hub](https://hub.docker.com/r/digdep/drupal-base/)

This is a base image for running Drupal 8 in development and CI. It does not come with Drupal itself, but it does come with:
* a properly configured NGINX (stable),
* a properly configured PHP-FPM (7.1),
* a supervisord configuration to run the aforementioned,
* Composer,
* Drush,
* Terminus,
* BusyBox sendmail—so you can set the `SMTPHOST` env variable to e.g. a MailHog container,
* dependencies for Cypress.io, and
* dependencies for CircleCI 2.0.

See `docker-compose.example.yml` for how to use.

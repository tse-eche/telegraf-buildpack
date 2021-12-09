# Telegraf Buildpack

This Sidecar Buildpack includes the `Telegraf v1.18.3`-binaries to the container, in which the application is deployed.
The configuration file of telegraf is prepared, to collect metrics from the container system.

Also this Sidecar provides the ability to add a Prometheus compatible metrics endpoint,to scrape metrics from the application, which is running in the container.

That these metrics can be collected a Graphite host must be defined to which the Telegraf will push the scraped metrics.
For that purpose the `App-Monitor`-BuildPack can be used (https://gitlabci.exxeta.com/paas_buildpacks/app-monitor).

The Sidecar provides follwing ENV-Variables:

| Name          | Description                                      | Default    |
| ------------- | ------------------------------------------------ | ---------- |
| PROM_HOST     | Host of the internal Prometheus metrics endpoint | localhost  |
| PROM_PORT     | Port of the internal Prometheus metrics endpoint | 9100       |
| PROM_PATH     | Path of the internal Prometheus metrics endpoint | /metrics   |
| PROM_ENABLED  | if 'false' Prometheus config will be skipped     | false      |
| GRAPHITE_HOST | Host of the Graphite Exporter metrics endpoint   | undefined  |
| GRAPHITE_PORT | Port of the Graphite Exporter metrics endpoint   | undefined  |
| DEBUG         | Increase the logs to stdout                      | false      |

If `GRAPHITE_HOST` and `GRAPHITE_PORT` not provided by 'REVEAL USER PROVIDED ENV VARS' the sidecar try to find this information in `VCAP_SERVICES` environmen variable, which will be automaticaly set if the app is binded to the `a9s-Prometheus` service.
If both are not set the Sidecar supply will fail.

## Installation

To add that Buildpack to your application, add the following lines to your manifest yml in your application.

```
  buildpacks:
    - https://gitlabci.exxeta.com/paas_buildpacks/telegraf-buildpack.git
    - { Your Application Buildpack }
```

ATTENTION, if you are not using a custom command in your manifest file, it is neccessary, to have the application buildpack as last in the buildpacks list, because that will create the startup command.

## Grafana
The `Grafana_Dashboard.json` inherits and Dashboard-Template for Grafana in Json-Fromat which can be used to start an Dashboard in Grafana.

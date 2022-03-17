# Telegraf Buildpack

This Sidecar Buildpack includes the `Telegraf v1.18.3`-binaries to the container, in which the application is deployed.
The configuration file of telegraf is prepared, to collect metrics from the container system.

## Types of Collected Metrics

Telegraf can collect an enourmous amount of different metric types like hardware, Prometheus compatible endpoints, Kafka, Gitlab, etc.
For the PaaS sidecar at the moment "only" hardware and Prometheus endpoint metrics are relevant. 

### Hardware Metrics

The sidecar collects by default the hardware metrics of the underlying system the PaaS application is running in.
These metrics are e.g.:
- CPU usage
- RAM usage
- Disk usage
- Network traffic
- ...

### Prometheus Endpoint Metrics

Also this Sidecar provides the ability to add a Prometheus compatible metrics endpoint, to scrape metrics from the application, which is running in the container.
To enable or disable the application specific metrics collection from an application the `ROM_ENABLED` configuration parameter is responsible. If it is disabled (default) no application metrics will be collected and only hardware metrics are part of the collector.

Telegraf is able to push to many different target systems, as well it is possible that metrics collection systems can scrape a Telegraf endpoint.
In this sidecar two different push targets are imlemented:
- Graphite compatible endpoint
- Prometheus Remote Write endpoint

## Types of Target Metric Storages

Telegraf can also send its collected metrics to many different storage systems, as as it can be scraped from such by providing a specific scraping endpoint.
For the PaaS sidecar at the moment "only" push to a Graphite compatible endpoints and Prometheus Remote Write endpoints are configurable. 

### Push to Graphite Compatible Endpoint

The metrics collected by Telegraf have to be send to a metrics database. This can be done by sending the metrics to a database which has a Graphite compatible endpoint. The `GRAPHITE_*` configuration parameters are responsible for setting this up.
For that purpose the `App-Monitor`-BuildPack can be used (https://gitlabci.exxeta.com/paas_buildpacks/app-monitor).

### Push to Prometheus Remote Write Endpoint

Telegraf is also able to send its metrics to a Prometheus store. Usually Prometheus scrapes its target on its own, but with the new RemoteWrite configuration it is possible that metrics can be actively send to Prometheus. To enable that feature the`PROM_REMOTE_WRITE_*` parameters are responsible.

Prometheus RemoteWrite functionality is disabled by default.
Currently Prometheus RemoteWrite functionality is only supported with Basic-Auth credentials.

## Sidecar Configuration Parameters

The Sidecar provides follwing ENV-Variables:

| Name                     | Description                                             | Default     |
| ------------------------ | ------------------------------------------------------- | ----------- |
| PROM_HOST                | Host of the internal Prometheus metrics endpoint        | localhost   |
| PROM_PORT                | Port of the internal Prometheus metrics endpoint        | 9100        |
| PROM_PATH                | Path of the internal Prometheus metrics endpoint        | /metrics    |
| PROM_ENABLED             | if 'false' Prometheus config will be skipped            | false       |
| GRAPHITE_HOST            | Host of the Graphite Exporter metrics endpoint          | undefined   |
| GRAPHITE_PORT            | Port of the Graphite Exporter metrics endpoint          | undefined   |
| DEBUG                    | Increase the logs to stdout                             | false       |
| PROM_REMOTE_WRITE_URL    | RemoteWrite-URL of Prometheus Instance                  | undefined   |
| PROM_REMOTE_WRITE_USER   | Basic Auth User of Remote Write Prometheus Instance     | undefined   |
| PROM_REMOTE_WRITE_PASSWD | Basic Auth Password of Remote Write Prometheus Instance | undefined   |

If `GRAPHITE_HOST` and `GRAPHITE_PORT` not provided by 'REVEAL USER PROVIDED ENV VARS' the sidecar tries to find this information in the `VCAP_SERVICES` environment variable, which will be automaticaly set if the app is binded to the `a9s-Prometheus` service.

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

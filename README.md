# Telegraf Buildpack

This Sidecar Buildpack includes the `Telegraf`-binaries to the container, in which the application is deployed.
The configuration file from Telegraf is prepared to collect metrics from the container system as well from a configurable
metrics endpoint of an application deployed inside the container.

This sidecare also provides the ability to add a Prometheus compatible metrics endpoint as configuration variable
which exposes metrics of the application running in the container.

That these metrics can be collected a Graphite host must be defined to which the Telegraf will push the scraped metrics.
For that purpose the `App-Monitor`-BuildPack can be used (https://gitlabci.exxeta.com/paas_buildpacks/app-monitor).


For this scenario the container provides the following ENV-Variables:

| Name          | Description                                                       |
| ------------- | ----------------------------------------------------------------- |
| PROM_HOST     | Host of the internal Prometheus metrics endpoint                  |
| PROM_PORT     | Port of the internal Prometheus metrics endpoint                  | 
| PROM_PATH     | Path of the internal Prometheus metrics endpoint                  |
| GRAPHITE_HOST | Host of the Graphite Exporter metrics endpoint                    |
| GRAPHITE_PORT | Port of the Graphite Exporter metrics endpoint                    |  
| NO_PROM       | If 'true', no Prometheus metrics endpoint will be monitored       |

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

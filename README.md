# Telegraf Buildpack

This Sidecar Buildpack includes the `Telegraf`-binaries to the container, in which the application is deployed.
The configuration file from telegraf is prepared to collect metrics from system.

For now the output is set to port 9100 for prometheus Server.
After the update of the a9s-prometheus-Service this package will provide metrics to the graphite exporter included in a9s-prometheus-Service.

This sidecare also provide the ability to add an prometheus-client as input, for example the application metrics.
For this scenario the container proviedes the following ENV-Variables:

| Name      | Description                            |
| --------- | -------------------------------------- |
| PROM_HOST | Host of the internal prometheus client |
| PROM_PORT | Port of the internal prometheus client | 
| PROM_PATH | Path of the internal prometheus client |

## Installation

To add that Buildpack to your application, add the following lines to your manifest yml in your application.

```
  buildpacks:
    - https://gitlabci.exxeta.com/paas_buildpacks/telegraf-buildpack.git
    - { Your Application Buildpack }
```

ATTENTION, if you are not useing a custom command in your manifest file, its neccessary, to have the application buildpack as last in the buildpacks list, because thats will create the startup command.

## Grafana
The `Grafana_Dashboard.json` inherits and Dashboard-Template for Grafana in Json-Fromat which can be used to start an Dashboard in Grafana.
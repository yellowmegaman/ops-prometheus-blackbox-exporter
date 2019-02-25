# ops-prometheus-blackbox-exporter

Allows you to deploy prometheus-blackbox-exporter via Nomad

Expects "DC" env variable.

Example:

```
levant deploy -address=http://your-nomad-installation-or-cluster:4646 -var-file=vars.yaml ops-prometheus-blackbox-exporter.nomad
```

job "prometheus-blackbox-exporter" {
  datacenters = ["[[env "DC"]]"]
  type = "system"
  group "prometheus-blackbox-exporter" {
    task "prometheus-blackbox-exporter" {
      template {
        data = <<EOH
modules:
  http_2xx:
    prober: http
    http:
  http_post_2xx:
    prober: http
    http:
      method: POST
  tcp_connect:
    prober: tcp
  pop3s_banner:
    prober: tcp
    tcp:
      query_response:
      - expect: "^+OK"
      tls: true
      tls_config:
        insecure_skip_verify: false
  ssh_banner:
    prober: tcp
    tcp:
      query_response:
      - expect: "^SSH-2.0-"
  irc_banner:
    prober: tcp
    tcp:
      query_response:
      - send: "NICK prober"
      - send: "USER prober prober prober :prober"
      - expect: "PING :([^ ]+)"
        send: "PONG ${1}"
      - expect: "^:[^ ]+ 001"
  icmp:
    prober: icmp
EOH
        destination         = "local/blackbox.yml"
        change_mode         = "signal"
        change_signal       = "SIGHUP"
      }
      artifact {
        source = "https://github.com/prometheus/blackbox_exporter/releases/download/v[[.prometheus-blackbox-exporter.version]]/blackbox_exporter-[[.prometheus-blackbox-exporter.version]].linux-amd64.tar.gz"
      }
      driver = "raw_exec"
      config {
        command = "blackbox_exporter-[[.prometheus-blackbox-exporter.version]].linux-amd64/blackbox_exporter"
        args = ["--config.file=local/blackbox.yml"]
      }
      resources {
        cpu    = 50
        memory = [[.prometheus-blackbox-exporter.ram]]
        network {
          mbits = 10
          port "healthcheck" { static = [[.prometheus-blackbox-exporter.port]] }
        }
      }
      service {
        name = "prometheus-blackbox-exporter"
        tags = ["[[.prometheus-blackbox-exporter.version]]"]
        port = "healthcheck"
        check {
          name     = "alive"
          type     = "tcp"
          interval = "10s"
          timeout  = "2s"
        }
      }
    }
  }
}

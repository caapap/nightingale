# stellar

星相V2版本默认只有一个组件，就是 stellar，也通过 `/metrics` 接口暴露了 Prometheus 协议的监控数据。如果使用边缘机房部署方案，会用到 stellar-edge，stellar-edge 也通过 `/metrics` 接口暴露了 Prometheus 协议的监控数据。

所以，通过 categraf 的 prometheus 插件即可采集星相的监控数据。

## 采集配置

categraf 的 `conf/input.prometheus/prometheus.toml`

```toml
[[instances]]
urls = [
  "http://IP:17000/metrics"
]
labels = {job="stellar"}
```

## Dashboard

星相内置了一个stellar_v2 仪表盘。


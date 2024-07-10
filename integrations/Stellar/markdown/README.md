# N9E

星相V6版本默认使用一个组件，n9e，通过 `/metrics` 接口暴露了 Prometheus 协议的监控数据。如果使用边缘机房部署方案，会用到 n9e-edge，n9e-edge 也通过 `/metrics` 接口暴露了 Prometheus 协议的监控数据。

所以，通过 categraf 的 prometheus 插件即可采集星相的监控数据。

## 采集配置

categraf 的 `conf/input.prometheus/prometheus.toml`

```toml
[[instances]]
urls = [
  "http://IP:17000/metrics"
]
labels = {job="n9e"}
```




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

## FAQ

### 1.数据源管理
#### 1.1.单个平台存在多数据源

##### 1.对于现场可能存在多个skynet平台，或多个k8s、星云平台数据源时，
可在skynet|ddp|k8s关键词后加入序号以区分，如skynet1、skynet2。
注意：数据源名称前缀必须按照prometheus-skynet|k8s|ddp填写。
之后，可在仪表盘内进行区分：

##### 2.同时，在机器资产模块，可按照打标签进行多平台区分以方便管理，如：
- platform=skynet1,platform=skynet2...

#### 1.2.平台数据源无法添加

1.检查端口号：不同平台版本存在端口差异问题，如大模型skynet的prometheus端口为30002，在添加时到各平台内确认即可。
2.检查ip地址：提前确认平台的监控组件部署位置，如skynet托管的ant-mon部署节点，要确认ant-mon的节点ip，而不是skynet-xmanager的节点ip。
3.检查各平台的prometheus组件是否运行正常，三平台都有独立的prometheus访问方式，以下为参考的页面访问地址：
- skynet：http://<antmon-ip>:19090
- skynet-星火：http://<antmon-ip>:30002
- ddp: http://<ddp-prometheus-ip>:9090
- k8s: http://prometheus-k8s.kubesphere-monitoring-system:9090

1.2.业务组管理
1.2.1.三平台之外的组件如何纳管

对于某些特殊情况，如现场存在暂未纳管到三平台的机器资产、软件服务，如额外部署的es服务器、原生组件的服务器、闲置的gpu服务器等，可以通过添加临时的业务组进行纳管，如在业务组管理中可以新建：
- 闲置机器
- ES集群
等业务组名称。
1.3.机器资产模块
1.3.1.机器数统计错误

- 问题描述：监控主机数与后台categraf部署机器总数不一致

- 问题分析：该指标由categraf采集器提供，通过count(system_load1)计算，只有当实际的统计数记录到prometheus库中，才是正确的数值。categraf下发时间和机器的ntp同步均会影响该值，在实际操作中，可以发现调整不同时间段统计数会发生变化。
- 解决步骤：
1.步骤一：若生产环境下允许，请同步所有主机的ntp时间，并控制延迟在100ms以下：

2.步骤二：访问prometheus后台数据目录，清空旧的指标数据即可。如下：
注：这里清除了过去的prometheus指标记录，因此会导致历史指标丢失，只建议部署阶段进行此操作。
若prometheus已经存放了半个月以上的指标记录，建议同步ntp后，等待一段时间后，监控机器数即可正常显示。



重启prometheus，并调整面板的时间范围为一分钟，等待面板刷新正确的结果。
1.3.2.categraf部署失败
注：目前categraf后台自动部署方式已更新，支持一键下发多系统架构，详见Categraf-Setup资源包中README文件。
1.检查机器是否关闭防火墙
2.检查是否关闭selinux
3.查看ansible部署报错日志，检查目标机器系统架构是否不支持，或系统是否缺少相关依赖
4.若仍无法部署，参考3.2章节进行categraf手动部署
1.3.3.如何利用打标签进行资产管理
基于部署视图打标签，完善资产管理模块，可以帮助我们提高服务器资产管理效率。
示例如下：

最佳案例：根据江苏现场标签使用的效果，有以下参考
- platform=bbt1|skynet-manager|AI中台|es-master|es-data1|spark-v3.5|OCR...
- gpu=Nvidia-T4|Ascend-910b3
- os=openEuler22.03|centos7.9|KylinV10|windows
- ntp-server=true
- yum-server=true
- ...
1.4.监控仪表盘模块
1.4.1.仪表盘所有指标无数据
- 问题描述：在正常添加三平台监控数据源后，并确认组件的exporter已成功部署，在三平台监控仪表盘上可以正常显示，但在星相上指标为空No Data。

- 问题分析：在成功接入prometheus数据源后，也就意味着星相具备了三平台同等的监控能力，若此时发现仪表盘无数据，可能的原因及解决方法如下：
1.时间太短：星相平台接入三方prometheus数据源需要等待时间刷新到本地的监控数据库中，此时若调整比较大的时间间隔，如“最近1小时”，这样超过了实际统计的指标数据范围，等待片刻或刷新较短时间间隔（如五分钟）即可。
2.数据源选择：


各业务组数据源变量，采用过滤格式，见上图。若出现datasource变为id号且此时无数据，重新选择数据源即可解决。

3.平台自身的监控组件异常：接入prometheus数据源并不意味着就可以实现所有的服务可观测能力。要确保各平台已发布或已具备的监控组件均已部署，三平台自身监控采集组件清单如下：
(1)skynet：参考ant-mon监控服务（支持2.1.x和3.4.x的skynet版本）
(2)k8s：参考《公共组件采集插件配置手册-v1.1.docx》，确保公共组件的采集插件已部署或已打开监控选项
(3)ddp：星云大数据平台组件监控，在大数据平台上对监控能力进行巡检。
1.4.2.exporter正常，但仪表盘部分指标无数据

解决方法：
部分仪表盘依赖于选定的全局变量，默认打开时为“all”，此时通过下拉菜单选中目标job或目标进程等采集对象即可。如：minio中需要关联对应的采集job、k8s集群监控的节点状态需要选中某个节点node等。
1.4.3.DDP组件监控状态异常
- 问题描述：在星相运维平台上查看大数据仪表盘无数据
- 问题分析：
情景1：目前星相支持16个监控ddp集群的仪表盘，但在实际业务场景，并非所有组件均已部署生效，如Spark、Flink等组件在业务中不需要部署，或者部分组件使用独立部署方式，如es。
情景2：大数据组件管理平台的监控插件启动异常，如在江苏dsj现场发现starrocks在ddp界面上宕机，但实际运行正常。这种情况就需要定向修复starrocks exporter启动的问题
- 解决步骤：
情景1：在仪表盘列表备注中，标记未生效仪表盘，方便后续管理。对于es独立组件，可以利用公共组件可观测部署文档进行监控部署，参考《公共组件采集插件配置手册-v1.1》。
情景2：根据exporter启动报错日志，找到对应的json启动文件，更改为正确端口配置，然后在界面上点击启动即可。
1.4.4.运维大屏中，skynet服务数不一致

解决方法：
1.确保skynet的ant-mon已成功部署，并检查“监控服务-管理中心”的采集任务是否自动发现，如下所示：

若存在缺失或报错，参考《skynet监控组件(ant-mon)部署手册v1.1.docx》手册进行排查。
注：其中zookeeper-exporter非必须
2.检查skynet平台是否存在已托管，但未启动的服务（灰色状态）。
1.4.5.仪表盘的内置变量清单
    { name: '__from', value: from },
    { name: '__from_date_seconds', value: fromDateSeconds },
    { name: '__from_date_iso', value: fromDateISO },
    { name: '__from_date', value: fromDateISO },
    { name: '__to', value: to },
    { name: '__to_date_seconds', value: toDateSeconds },
    { name: '__to_date_iso', value: toDateISO },
    { name: '__to_date', value: toDateISO },
    { name: '__interval', value: `${interval}s` },
    { name: '__interval_ms', value: `${interval * 1000}ms` },
    { name: '__rate_interval', value: `${interval * 4}s` },
    { name: '__range', value: `${toDateSeconds - fromDateSeconds}s` },
    { name: '__range_s', value: `${toDateSeconds - fromDateSeconds}s` },
    { name: '__range_ms', value: `${(toDateSeconds - fromDateSeconds) * 1000}ms` }
以获取大盘时间间隔为例，可以用$__interval来引用，例如 cpu_usage_active[$__interval] 另外文本卡片暂不支持内置变量。
1.5.告警规则模块
1.5.1.告警规则中的执行频率和持续时长？

告警规则里有3个配置非常关键，
- promql
- 执行频率
- 持续时长
意思就是按照执行频率，每隔一段时间执行promql查询（即时查询，即调用Prometheus协议的/api/v1/query接口），如果查到数据就认为触发了阈值，触发了阈值是否会产生告警事件，不一定，还要看持续时长，如果持续时长为0，就相当于不用等待，触发了阈值就立马生成事件，如果持续时长大于0，那就要等待，要保证持续时长这段时间内，每次执行promql的查询都触发阈值，才认为应该生成事件。
比如promql为 cpu_usage_idle{cpu="cpu-total"} < 20，执行频率是15s，持续时长是60s，就表示在60s内每15s执行一次promql查询，看promql查询是否返回内容，如果6次都返回了，说明应该生成告警事件。
1.6.治愈脚本模块
1.6.1.脚本执行的范围
1.脚本执行的范围：脚本的创建时，与业务组强关联，也就是说脚本只能作用于一个业务组，不能全局执行，如下图所示：

1.6.2.筛选机器列表



1.在创建或编辑脚本时，可以进行机器列表的筛选，如全部执行或根据匹配规则，进行部分机器执行。定义好机器列表后，下一次在创建脚本任务时，将默认显示预置的机器列表。
2.在执行脚本时（即创建任务），可以使用默认机器列表，也可以自定义。注意：创建脚本任务前，切记检查目标机器列表是否正确。
1.6.3.脚本执行的顺序

脚本执行前，可以按需调整脚本任务的并发度。
对于需要按机器编号顺序来进行输出结果查看的时候，可以使用1或2的并发度来进行输出结果的排版。若不调整使用默认0执行时，这时输出结果将按照机器号随机顺序进行结果显示。
1.7.其它
1.7.1.容量规划问题
星相Stellar监控系统的容量与以下因素有关：
- 三平台prometheus接入的指标数量
- 指标的平均采集频率
而指标采集的数据统一存放于星相平台的时序库中，也就是说时序库是占用资源大小的关键组件。
对于公司业务机器的运行规模来说，我们选用8C 16G的配置规格已经完全足够。若对负载测试感兴趣，建议使用以下测试思路：
(1)先找一个小规格的机器，比如4C8G，然后监控100台机器以及这些机器上面的中间件和应用程序
(2)运行一段时间，看看这个机器的资源使用情况，比如CPU、内存、磁盘增速等等
(3)之后就可以根据这些数据，来估算接入全业务的监控需要多大的机器规格了
这里提供一个参考的案例数据：
使用 SSD 的机器，32C 64G 的规格，每秒接收50万监控数据点是问题不大的。那每秒50万数据点是个什么概念呢？对于机器监控，如果只是监控CPU、内存、磁盘、网络、IO相关的常规指标，大概有150个指标，假设15秒采集一次，平均每秒采集10个指标。
50w / 10 = 5w
相当于这么一台机器可以支撑 5 万台机器的常规指标监控。
1.7.2.categraf采集器的资源消耗情况？
根据开源社区的测评数据，运行在4C8G的主机上，在采集了cpu/内存/磁盘/网络/进程等相关的指标140+时，categraf资源消耗情况如下：
采集器	CPU	内存(MB)	进程数
zabbix	<1%	17.4	6
categraf	<1%	85.7	1
telegraf	<1%	60.2	1
categraf-slim	<1%	45.2	1
对于我们的业务运行来说，采集器负载可以忽略不计，如果采集器所在的宿主机对于资源消耗非常敏感，那么建议给采集器通过cgroup等方式设定资源的使用上限。
1.7.3.Categraf修改配置后是否要重启
修改 categraf 配置文件后，需要进行reload ，有两种方式：
1.手动给categraf下发一个HUP信号
kill -HUP `pidof categraf`
2.或者重启Categraf
systemctl restart categraf
1.7.4.如何备份平台数据
星相平台的数据资产存放于后台mysql库中，我们在给前场下发仪表盘、告警规则、脚本等升级资源时，制作了sql的备份迁移方案，如下：
#### 数据库dump流程

1. a-n9e.sql

```sql
# part1
# 过滤临时数据表，dump固定数据表（仪表盘、告警规则等）
mysqldump -uroot -h 172.30.137.161 -p -P 19117 --ignore-table=n9e_v6.alert_cur_event --ignore-table=n9e_v6.alert_his_event --ignore-table=n9e_v6.target --ignore-table=n9e_v6.task_record --ignore-table=n9e_v6.metric_view n9e_v6 > a-n9e.sql
#加入如下初始化字段到a-n9e.sql
set names utf8mb4;
drop database if exists n9e_v6;
create database n9e_v6;
use n9e_v6;

```

2. b-ibex.sql （无需dump）
3. c-nodata.sql

```shell
# part2
# dump除part1外剩余的临时表结构（活跃告警、历史告警等）
mysqldump -uroot -h 172.30.137.161 -p -P 19117 --no-data n9e_v6 target alert_cur_event alert_his_event task_record metric_view > c-nodata.sql
# 加入如下初始化字段到c-nodata.sql
set names utf8mb4;
use n9e_v6;
```
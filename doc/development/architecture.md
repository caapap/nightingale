架构图
    Client[客户端] --> Gateway[API Gateway]
    Gateway --> Center[控制中心/Center]
    Gateway --> Alert[告警引擎/Alert]
    Gateway --> Transfer[传输层/Transfer]
    Gateway --> Index[索引服务/Index]
    
    Transfer --> TSDB[(时序数据库)]
    Transfer --> Redis[(Redis缓存)]
    
    Alert --> Redis
    Alert --> TSDB
    
    Center --> MySQL[(MySQL)]
    Center --> Redis
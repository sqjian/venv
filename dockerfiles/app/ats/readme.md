## 1、常用配置 

**ip_allow.yaml**

```yaml
ip_allow:
  - apply: in
    ip_addrs: 0.0.0.0/0
    action: allow
    methods: ALL
  - apply: in
    ip_addrs: ::/0
    action: allow
    methods: ALL
```

**plugin.config**

```bash
# 启用监控
stats_over_http.so --integer-counters --wrap-counters
```

**records.config**

```bash
# 开启在缓存中固定部分数据
CONFIG proxy.config.cache.permit.pinning INT 1
# 关闭VIA请求到原服务器头部信息
CONFIG proxy.config.http.insert_request_via_str INT 0
# 配置缓存服务器响应头部
CONFIG proxy.config.http.insert_response_via_str INT 2
# 内存缓存大小
CONFIG proxy.config.cache.ram_cache.size INT 64GB
# 缓存单个文件最大尺寸
CONFIG proxy.config.cache.ram_cache_cutoff INT 100MB
# 磁盘单个文件最大尺寸
CONFIG proxy.config.cache.max_doc_size INT 4M
# 启用http对象缓存
CONFIG proxy.config.http.cache.http INT 1
# 启用反向代理支持
CONFIG proxy.config.reverse_proxy.enabled INT 1
# 配置trafficserver仅为映射文件中匹配提供服务
CONFIG proxy.config.url_remap.remap_required INT 1
# 服务端口
CONFIG proxy.config.http.server_ports STRING 8080 8080:ipv6
# 开启 http ui
CONFIG proxy.config.http_ui_enabled INT 3
```

**remap.config**

```bash
map /cache-internal/ http://{cache-internal}
map /cache/ http://{cache}
map /hostdb/ http://{hostdb}
map /net/ http://{net}
map /http/ http://{http}

map / http://127.0.0.1:80
```

**storage.config**

```bash
/cache/trafficserver 1G
```

## 2、常用操作 

**query**

```bash
curl -i 'x.x.x.x:x/x' 
```

**delete**

```bash
curl -vX PURGE http://x.x.x.x/x
```

## 3、日常维护 

**log view**

```bash
bin/traffic_logcat -f logfile_path
```

**config update**

```bash
bin/traffic_ctl config reload
```

**monitor**

```bash
#plugins.config
stats_over_http.so --integer-counters --wrap-counters

curl http://ip:port/_stats
```

**http_ui**

```bash
http://x.x.x.x:xxxx/cache-internal/
http://x.x.x.x:xxxx/cache/
http://x.x.x.x:xxxx/hostdb/
http://x.x.x.x:xxxx/net/
http://x.x.x.x:xxxx/http/
```

## 4、性能评估

```shell
# input: 起100个连接使用127.0.0.1的9080端口作为jtest源服务器（jtest监听），对本机（localhost）的8080端口上跑的ATS进行测试，并控制整体命中率在40%
# -s: 源端口100个连接
# -S: 源地址
# -p: 目标端口
# -P: 目标地址
# -c: 100个连接
# -z: 整体命中率40%

# output：
# con: 并发连接数。并发连接数，单进程单cpu处理能力取决于CPU与测试场景，请酌情设置，推荐小于9999
# new: 每秒新建连接数。这个参数取决于并发连接数量与长连接效率
# ops: 每秒请求数。也作qps，是比较体现服务器性能的关键指标
# 1byte：首字节平均响应时间。这个是体现整体转发效率的关键指标
# lat: 完成请求整体响应时间（收到最后一个字节）。cache系统性能关键指标
# bytes/per：每秒字节流量/每秒每连接流量
# svrs：服务器端请求数
# new：服务器端新建连接数
# ops：服务器端每秒请求数
# total：服务器端总请求的字节数
# time：测试时间（秒）
# err：出错数量（连接数）

./jtest -s 9080 -S localhost -p 8080 -P localhost -c 100 -z 0.4
```
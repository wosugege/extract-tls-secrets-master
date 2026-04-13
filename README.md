# extract-tls-secrets

改自：https://github.com/neykov/extract-tls-secrets/tree/master?tab=readme-ov-file

jattach地址：https://github.com/jattach/jattach?tab=readme-ov-file

## 使用方式

### 直接启用
```shell script
./jattach 3784617 load instrument false "/data/sjc/ec/jm-tls-secrets-4.1.2.jar=http://localhost:8091/tlsKey.do"
```

```shell script
./jattach <pid> load instrument false "/data/sjc/ec/jm-tls-secrets-4.1.2.jar=调用接口的全路径"
```
### 开启
```shell script

sh inject.sh 8080,10179 /data/sjc/ec/jm-tls-secrets-4.1.2.jar http://127.0.0.1:8091/tlsKey.do@true
```

### 关闭
```shell script

sh inject.sh 8080,10179 /data/sjc/ec/jm-tls-secrets-4.1.2.jar http://127.0.0.1:8091/tlsKey.do
```
## 说明

配合jattach进行注入可解决环境上的tools.jar冲突和不存在等问题

## 编译
拉去代码至本地后需要主语tool.jar的引入，已在pom.xml文件中引入tools.jar的相对路径，请配置JAVA_HOME路径以使其生效
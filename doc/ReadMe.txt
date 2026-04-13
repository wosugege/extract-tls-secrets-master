./jattach 3784617 load instrument false "/data/sjc/ec/jm-tls-secrets-4.1.2.jar=http://localhost:8091/tlsKey.do"


./jattach <pid> load instrument false "/data/sjc/ec/jm-tls-secrets-4.1.2.jar=调用接口的全路径"

开启
sh inject.sh 8080,10179 /data/sjc/ec/jm-tls-secrets-4.1.2.jar http://127.0.0.1:8091/tlsKey.do@true

关闭
sh inject.sh 8080,10179 /data/sjc/ec/jm-tls-secrets-4.1.2.jar http://127.0.0.1:8091/tlsKey.do
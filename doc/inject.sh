#!/bin/bash

# ==================== 【终极方案】精准杀死旧脚本进程（适配sh运行） ====================
# 获取脚本的绝对路径，避免匹配其他同名脚本
SCRIPT_ABS_PATH=$(readlink -f "$0")

# 遍历所有bash/sh进程，精准匹配脚本绝对路径，排除当前进程
for pid in $(ps -eo pid,cmd | grep -F "$SCRIPT_ABS_PATH" | grep -v "$$" | awk '{print $1}'); do
    echo "⚠️  发现旧监控进程 $pid，正在杀死..."
    kill -9 "$pid" >/dev/null 2>&1
    sleep 0.3
done

echo "✅ 旧进程清理完成，启动新监控..."
# ==================================================================================

# ==================== 参数判断 ====================
if [ $# -lt 3 ]; then
    echo "用法: $0 <端口1,端口2,...> <agent.jar路径> <上报接口URL>"
    echo "示例: $0 8080,10179 /data/sjc/ec/jm-tls-secrets-4.1.2.jar http://127.0.0.1:8091/tlsKey.do"
    exit 1
fi

# ==================== 变量配置 ====================
PORTS="$1"
AGENT_JAR="$2"
API_URL="$3"
JATTACH="./jattach"
CHECK_INTERVAL=3

# 把端口转成数组
IFS=',' read -ra PORT_ARR <<< "$PORTS"

# 记录每个端口已经注入的PID，防止重复注入
declare -A INJECTED_PID

# 注入失败的端口不再处理
declare -A FAILED_PORTS

echo "==================== 多端口TLS自动注入监控 ===================="
echo "监听端口 : ${PORT_ARR[@]}"
echo "Agent包  : $AGENT_JAR"
echo "上报接口 : $API_URL"
echo "=============================================================="

# 注入函数
do_inject() {
    local port="$1"
    local pid="$2"
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] 端口 $port → 注入 PID: $pid"
    $JATTACH "$pid" load instrument false "$AGENT_JAR=$API_URL"
    if [ $? -eq 0 ]; then
        INJECTED_PID[$port]="$pid"
        echo "[$(date '+%Y-%m-%d %H:%M:%S')] 端口 $port → ✅ 注入成功"
    else
        FAILED_PORTS[$port]="1"
        echo "[$(date '+%Y-%m-%d %H:%M:%S')] 端口 $port → ❌ 注入失败，不再处理"
    fi
}

# 循环监控
while true; do
    for port in "${PORT_ARR[@]}"; do
        # 注入失败的端口不再处理
        if [[ -n "${FAILED_PORTS[$port]}" ]]; then
            continue
        fi

        # 获取端口对应的PID（优化版，兼容ss/netstat）
        pid=$(ss -lntp 2>/dev/null | grep -E ":${port}\b" | grep -o 'pid=[0-9]\+' | head -n1 | sed 's/pid=//g')
        if [ -z "$pid" ]; then
            pid=$(netstat -lntp 2>/dev/null | grep -E ":${port}\b" | grep -o 'pid=[0-9]\+' | head -n1 | sed 's/pid=//g')
        fi

        if [ -z "$pid" ]; then
            INJECTED_PID[$port]=""
            continue
        fi

        # 进程存活
        if ps -p "$pid" >/dev/null 2>&1; then
            if [ "${INJECTED_PID[$port]}" != "$pid" ]; then
                do_inject "$port" "$pid"
            fi
        else
            INJECTED_PID[$port]=""
        fi
    done
    sleep $CHECK_INTERVAL
done
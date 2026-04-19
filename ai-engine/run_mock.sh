#!/bin/bash
# WanderP AI Engine - Mock 模式启动脚本
# 使用本地 Mock 数据运行，无需外部 API（LLM、Milvus、Redis 等）

set -e

cd "$(dirname "$0")"

echo "========================================"
echo "  WanderP AI Engine - Mock 模式启动"
echo "========================================"
echo ""

# 设置环境变量
export USE_MOCK_DATA=true
export APP_ENV=development

echo "[1/3] 安装依赖..."
pip install -r requirements.txt --break-system-packages -q 2>/dev/null || \
pip install -r requirements.txt -q 2>/dev/null || \
echo "  部分依赖安装失败，尝试继续启动..."

echo "[2/3] 检查 Mock 数据..."
if [ -f "data/mock/hangzhou_data.json" ] && [ -f "data/mock/beijing_data.json" ]; then
    echo "  Mock 数据检查通过"
else
    echo "  警告: Mock 数据文件不完整"
fi

echo "[3/3] 启动服务..."
echo "  访问地址: http://localhost:8005"
echo "  API 文档: http://localhost:8005/docs"
echo ""

python -m uvicorn app.main:app --host 0.0.0.0 --port 8005 --reload

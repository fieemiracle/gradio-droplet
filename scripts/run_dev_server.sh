#!/bin/bash

# 运行 Gradio 开发服务器
# 可以在任何目录下执行此脚本

set -e  # 遇到错误立即退出

# 获取脚本所在目录的绝对路径
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# 获取项目根目录（scripts 的父目录）
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

# 切换到项目根目录
cd "$PROJECT_ROOT"

echo "=========================================="
echo "🚀 启动 Gradio 开发服务器"
echo "=========================================="
echo "项目目录: $PROJECT_ROOT"
echo ""

# 检查虚拟环境
if [ -d ".venv" ]; then
    echo "✓ 检测到虚拟环境: .venv"

    # 激活虚拟环境
    if [ -f ".venv/bin/activate" ]; then
        source .venv/bin/activate
        echo "✓ 虚拟环境已激活"
    fi
elif [ -d "venv" ]; then
    echo "✓ 检测到虚拟环境: venv"

    # 激活虚拟环境
    if [ -f "venv/bin/activate" ]; then
        source venv/bin/activate
        echo "✓ 虚拟环境已激活"
    fi
else
    echo "⚠ 警告: 未检测到虚拟环境"
    echo "   建议先创建虚拟环境: python3 -m venv .venv"
fi

echo ""

# 检查 dev_server.py 是否存在
if [ ! -f "examples/dev_server.py" ]; then
    echo "❌ 错误: 找不到 examples/dev_server.py"
    exit 1
fi

# 检查必要的依赖
echo "检查依赖..."
if ! python -c "import gradio" 2>/dev/null; then
    echo "❌ 错误: gradio 未安装"
    echo "   请运行: pip install -r requirements.txt"
    exit 1
fi

if ! python -c "import fastapi" 2>/dev/null; then
    echo "❌ 错误: fastapi 未安装"
    echo "   请运行: pip install fastapi uvicorn"
    exit 1
fi

echo "✓ 依赖检查通过"
echo ""

# 运行开发服务器
echo "启动服务器..."
echo "=========================================="
echo ""

python examples/dev_server.py

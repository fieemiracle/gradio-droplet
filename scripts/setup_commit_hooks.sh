#!/bin/bash
# Commit 规范设置脚本
# 用途: 一键配置 commit 规范和 pre-commit hooks
# 使用: ./scripts/setup_commit_hooks.sh

set -e

# 颜色输出
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${GREEN}=== Commit 规范设置脚本 ===${NC}\n"

# 检查虚拟环境
if [ -z "$VIRTUAL_ENV" ]; then
    echo -e "${RED}错误: 请先激活虚拟环境${NC}"
    echo "运行: source venv/bin/activate"
    exit 1
fi

echo -e "${YELLOW}步骤 1/5: 安装依赖${NC}"
pip install pre-commit commitizen isort
echo -e "${GREEN}✓ 依赖已安装${NC}\n"

echo -e "${YELLOW}步骤 2/5: 安装 pre-commit hooks${NC}"
pre-commit install
pre-commit install --hook-type commit-msg
echo -e "${GREEN}✓ Pre-commit hooks 已安装${NC}\n"

echo -e "${YELLOW}步骤 3/5: 设置 git commit 模板${NC}"
git config commit.template .gitmessage
echo -e "${GREEN}✓ Commit 模板已设置${NC}\n"

echo -e "${YELLOW}步骤 4/5: 运行初始检查${NC}"
pre-commit run --all-files || true
echo -e "${GREEN}✓ 初始检查完成${NC}\n"

echo -e "${YELLOW}步骤 5/5: 测试 commit 规范${NC}"
echo "测试 commit 消息格式..."
echo "feat: test commit message" | cz check --commit-msg-file /dev/stdin && \
    echo -e "${GREEN}✓ Commit 规范测试通过${NC}\n" || \
    echo -e "${RED}✗ Commit 规范测试失败${NC}\n"

echo -e "${GREEN}=== 设置完成 ===${NC}\n"
echo "现在你可以："
echo "1. 使用交互式 commit: cz commit"
echo "2. 使用普通 commit: git commit -m 'feat: add new feature'"
echo "3. 查看规范文档: docs/COMMIT_CONVENTION.md"
echo ""
echo "每次 commit 时会自动："
echo "- 检查 commit 消息格式"
echo "- 运行代码格式化（black, isort）"
echo "- 运行代码检查（flake8）"

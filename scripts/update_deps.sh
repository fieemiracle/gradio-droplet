#!/bin/bash
# 依赖更新脚本
# 用途: 升级依赖并自动更新所有配置文件
# 使用: ./scripts/update_deps.sh [package_name]
#      或在任何目录: bash scripts/update_deps.sh [package_name]

set -e  # 遇到错误立即退出

# 颜色输出
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# 获取脚本所在目录
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# 获取项目根目录（脚本在 scripts/ 目录下）
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

echo -e "${GREEN}=== 依赖更新脚本 ===${NC}\n"
echo "项目根目录: $PROJECT_ROOT"
echo ""

# 切换到项目根目录
cd "$PROJECT_ROOT"

# 检查虚拟环境
if [ -z "$VIRTUAL_ENV" ]; then
    echo -e "${RED}错误: 请先激活虚拟环境${NC}"
    echo "运行: source venv/bin/activate 或 source .venv/bin/activate"
    exit 1
fi

# 检查必要文件是否存在
if [ ! -f "requirements.txt" ] && [ ! -f "requirements-dev.txt" ]; then
    echo -e "${RED}错误: 找不到 requirements.txt 或 requirements-dev.txt${NC}"
    echo "当前目录: $(pwd)"
    exit 1
fi

# 获取要升级的包名
PACKAGE=${1:-"gradio"}

echo -e "${YELLOW}步骤 1/6: 备份当前依赖${NC}"
pip freeze > requirements.backup
echo "✓ 已备份到 requirements.backup"

echo -e "\n${YELLOW}步骤 2/6: 升级 $PACKAGE${NC}"
pip install --upgrade "$PACKAGE"
echo "✓ $PACKAGE 已升级"

echo -e "\n${YELLOW}步骤 3/6: 查看新版本${NC}"
NEW_VERSION=$(pip show "$PACKAGE" | grep "Version:" | cut -d " " -f 2)
echo "✓ $PACKAGE 新版本: $NEW_VERSION"

echo -e "\n${YELLOW}步骤 4/6: 更新 requirements 文件${NC}"
UPDATED=false

# 检查是否在 requirements.txt 中
if [ -f "requirements.txt" ] && grep -q "^$PACKAGE==" requirements.txt; then
    # macOS 的 sed 需要 -i '' 或 -i.bak
    if [[ "$OSTYPE" == "darwin"* ]]; then
        sed -i '' "s/^$PACKAGE==.*/$PACKAGE==$NEW_VERSION/" requirements.txt
    else
        sed -i "s/^$PACKAGE==.*/$PACKAGE==$NEW_VERSION/" requirements.txt
    fi
    echo "✓ 已更新 requirements.txt"
    UPDATED=true
fi

# 检查是否在 requirements-dev.txt 中
if [ -f "requirements-dev.txt" ] && grep -q "^$PACKAGE==" requirements-dev.txt; then
    if [[ "$OSTYPE" == "darwin"* ]]; then
        sed -i '' "s/^$PACKAGE==.*/$PACKAGE==$NEW_VERSION/" requirements-dev.txt
    else
        sed -i "s/^$PACKAGE==.*/$PACKAGE==$NEW_VERSION/" requirements-dev.txt
    fi
    echo "✓ 已更新 requirements-dev.txt"
    UPDATED=true
fi

if [ "$UPDATED" = false ]; then
    echo "⚠ 警告: $PACKAGE 不在 requirements 文件中"
    echo "   如果这是新依赖，请手动添加到 requirements.txt 或 requirements-dev.txt"
fi

echo -e "\n${YELLOW}步骤 5/6: 重新生成 requirements.lock${NC}"
pip freeze > requirements.lock
echo "✓ 已更新 requirements.lock"

echo -e "\n${YELLOW}步骤 6/6: 运行测试${NC}"
# 运行测试，但不因为没有测试而失败
if pytest --collect-only -q 2>&1 | grep -q "no tests ran"; then
    echo "⚠ 没有找到测试文件，跳过测试"
    TEST_PASSED=true
elif pytest; then
    echo -e "${GREEN}✓ 测试通过${NC}"
    TEST_PASSED=true
else
    echo -e "${RED}✗ 测试失败${NC}"
    TEST_PASSED=false
fi

if [ "$TEST_PASSED" = false ]; then
    echo -e "\n${YELLOW}是否回滚到之前的版本? (y/n)${NC}"
    read -r ROLLBACK
    if [ "$ROLLBACK" = "y" ]; then
        echo "回滚中..."
        pip install -r requirements.backup
        echo "✓ 已回滚"
        rm requirements.backup
        exit 1
    fi
fi

echo -e "\n${GREEN}=== 更新完成 ===${NC}"
echo -e "\n📝 更新的文件:"
if [ "$UPDATED" = true ]; then
    echo "   - requirements.txt 或 requirements-dev.txt"
fi
echo "   - requirements.lock"
echo "   - requirements.backup (备份文件)"

echo -e "\n📋 下一步:"
echo "1. 检查更新: git diff requirements*.txt requirements.lock"
echo "2. 测试应用: python examples/app.py"
echo "3. 提交更改: git add requirements*.txt requirements.lock"
echo "4. 创建提交: git commit -m 'chore: update $PACKAGE to $NEW_VERSION'"
echo "5. 推送代码: git push"

echo -e "\n💡 提示:"
echo "   - 备份文件: requirements.backup"
echo "   - 如需回滚: pip install -r requirements.backup"
echo "   - 完成后可删除备份: rm requirements.backup"

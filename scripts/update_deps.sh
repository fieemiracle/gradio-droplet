#!/bin/bash
# 依赖更新脚本
# 用途: 升级依赖并自动更新所有配置文件
# 使用: ./scripts/update_deps.sh [package_name]
# chmod +x scripts/update_deps.sh 给予足够权限

set -e  # 遇到错误立即退出

# 颜色输出
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}=== 依赖更新脚本 ===${NC}\n"

# 检查虚拟环境
if [ -z "$VIRTUAL_ENV" ]; then
    echo -e "${RED}错误: 请先激活虚拟环境${NC}"
    echo "运行: source venv/bin/activate"
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

echo -e "\n${YELLOW}步骤 4/6: 更新 requirements.txt${NC}"
# 检查是生产依赖还是开发依赖
if grep -q "^$PACKAGE" requirements.txt; then
    # 更新 requirements.txt
    sed -i.bak "s/^$PACKAGE==.*/$PACKAGE==$NEW_VERSION/" requirements.txt
    rm requirements.txt.bak
    echo "✓ 已更新 requirements.txt"
elif grep -q "^$PACKAGE" requirements-dev.txt; then
    # 更新 requirements-dev.txt
    sed -i.bak "s/^$PACKAGE==.*/$PACKAGE==$NEW_VERSION/" requirements-dev.txt
    rm requirements-dev.txt.bak
    echo "✓ 已更新 requirements-dev.txt"
else
    echo "⚠ 警告: $PACKAGE 不在 requirements 文件中，请手动添加"
fi

echo -e "\n${YELLOW}步骤 5/6: 重新生成 requirements.lock${NC}"
pip freeze > requirements.lock
echo "✓ 已更新 requirements.lock"

echo -e "\n${YELLOW}步骤 6/6: 运行测试${NC}"
if pytest; then
    echo -e "${GREEN}✓ 测试通过${NC}"
else
    echo -e "${RED}✗ 测试失败${NC}"
    echo -e "${YELLOW}是否回滚到之前的版本? (y/n)${NC}"
    read -r ROLLBACK
    if [ "$ROLLBACK" = "y" ]; then
        echo "回滚中..."
        pip install -r requirements.backup
        echo "✓ 已回滚"
        exit 1
    fi
fi

echo -e "\n${GREEN}=== 更新完成 ===${NC}"
echo -e "\n下一步:"
echo "1. 检查更新: git diff"
echo "2. 测试应用: python examples/app.py"
echo "3. 提交更改: git add requirements*.txt requirements.lock"
echo "4. 创建提交: git commit -m 'Update $PACKAGE to $NEW_VERSION'"
echo "5. 推送代码: git push"
echo -e "\n如需回滚: pip install -r requirements.backup"

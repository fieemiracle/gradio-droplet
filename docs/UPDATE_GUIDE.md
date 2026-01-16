# 依赖更新指南

## 重要概念

### pip install --upgrade 不会自动更新配置文件！

```bash
pip install --upgrade gradio
```

这个命令**只会**：
- ✅ 升级虚拟环境中的包
- ✅ 更新 `venv/lib/python3.x/site-packages/`

**不会**：
- ❌ 修改 `requirements.txt`
- ❌ 修改 `requirements.lock`
- ❌ 修改 `pyproject.toml`

## 为什么不会自动更新？

1. **配置文件是静态文本**，pip 不会修改它们
2. **版本更新需要测试**，不应该自动进行
3. **避免意外破坏**，保持可控性

## 手动更新流程

### 方法 1: 完整手动流程

```bash
# 1. 备份当前依赖
pip freeze > requirements.backup

# 2. 升级包
pip install --upgrade gradio

# 3. 查看新版本
pip show gradio
# 输出: Version: 6.5.0

# 4. 手动更新 requirements.txt
# 编辑文件，将 gradio==6.3.0 改为 gradio==6.5.0

# 5. 重新生成 requirements.lock
pip freeze > requirements.lock

# 6. 运行测试
pytest
python examples/app.py

# 7. 提交更改
git add requirements.txt requirements.lock
git commit -m "Update gradio to 6.5.0"
git push
```

### 方法 2: 使用自动化脚本（推荐）⭐

```bash
# 升级 gradio
./scripts/update_deps.sh gradio

# 升级其他包
./scripts/update_deps.sh pytest
./scripts/update_deps.sh black
```

脚本会自动：
1. ✅ 备份当前依赖
2. ✅ 升级指定的包
3. ✅ 更新 requirements.txt 或 requirements-dev.txt
4. ✅ 重新生成 requirements.lock
5. ✅ 运行测试
6. ✅ 如果测试失败，提示回滚

### 方法 3: 使用 pip-tools（高级）

```bash
# 安装 pip-tools
pip install pip-tools

# 创建 requirements.in（输入文件）
echo "gradio>=6.3.0" > requirements.in

# 生成锁定文件
pip-compile requirements.in -o requirements.lock

# 升级所有依赖
pip-compile --upgrade requirements.in -o requirements.lock

# 安装锁定的版本
pip-sync requirements.lock
```

## 常见场景

### 场景 1: 升级单个包

```bash
# 使用脚本（推荐）
./scripts/update_deps.sh gradio

# 或手动
pip install --upgrade gradio
pip show gradio  # 查看版本
# 手动编辑 requirements.txt
pip freeze > requirements.lock
```

### 场景 2: 升级所有包

```bash
# 1. 备份
pip freeze > requirements.backup

# 2. 升级所有包
pip install --upgrade -r requirements.txt
pip install --upgrade -r requirements-dev.txt

# 3. 查看变化
pip list

# 4. 重新生成所有文件
pip freeze > requirements.lock

# 5. 手动更新 requirements.txt 和 requirements-dev.txt
# 根据 pip list 输出更新版本号

# 6. 测试
pytest
python examples/app.py

# 7. 如果有问题，回滚
pip install -r requirements.backup
```

### 场景 3: 添加新依赖

```bash
# 1. 安装新包
pip install requests

# 2. 查看版本
pip show requests
# Version: 2.31.0

# 3. 添加到 requirements.txt
echo "requests==2.31.0" >> requirements.txt

# 4. 更新 requirements.lock
pip freeze > requirements.lock

# 5. 更新 pyproject.toml
# 手动编辑，在 dependencies 中添加:
# "requests>=2.31.0",

# 6. 提交
git add requirements.txt requirements.lock pyproject.toml
git commit -m "Add requests dependency"
```

### 场景 4: 移除依赖

```bash
# 1. 卸载包
pip uninstall gradio-client

# 2. 从 requirements.txt 中删除该行
# 手动编辑文件

# 3. 更新 requirements.lock
pip freeze > requirements.lock

# 4. 从 pyproject.toml 中删除
# 手动编辑文件

# 5. 提交
git add requirements.txt requirements.lock pyproject.toml
git commit -m "Remove gradio-client dependency"
```

## 版本冲突处理

### 问题：升级后出现版本冲突

```bash
# 错误示例
ERROR: pip's dependency resolver does not currently take into account all the packages that are installed.
This behaviour is the source of the following dependency conflicts.
gradio 6.3.0 requires pydantic>=2.0.0, but you have pydantic 1.10.0 which is incompatible.
```

### 解决方案

```bash
# 1. 查看冲突
pip check

# 2. 升级冲突的包
pip install --upgrade pydantic

# 3. 或者降级主包
pip install gradio==6.2.0

# 4. 更新配置文件
pip freeze > requirements.lock
```

## 测试更新

### 基本测试

```bash
# 1. 运行单元测试
pytest

# 2. 运行应用
python examples/app.py

# 3. 检查导入
python -c "import gradio; print(gradio.__version__)"
```

### 完整测试

```bash
# 1. 运行所有测试
pytest -v

# 2. 检查代码质量
black --check .
flake8 gradio_droplet tests
mypy gradio_droplet

# 3. 运行示例应用
python examples/app.py
# 手动测试功能

# 4. 检查依赖树
pip install pipdeptree
pipdeptree -p gradio
```

## 回滚更新

### 如果更新出现问题

```bash
# 方法 1: 使用备份文件
pip install -r requirements.backup

# 方法 2: 安装特定版本
pip install gradio==6.3.0

# 方法 3: 使用 git 恢复
git checkout requirements.txt requirements.lock
pip install -r requirements.txt
```

## 团队协作

### 其他人如何同步更新

```bash
# 1. 拉取最新代码
git pull

# 2. 查看变化
git log --oneline -5
git diff HEAD~1 requirements.txt

# 3. 更新依赖
pip install -r requirements.txt
pip install -r requirements-dev.txt

# 或使用锁定文件
pip install -r requirements.lock

# 4. 验证
pip list
pytest
```

## 自动化工具对比

| 工具 | 优点 | 缺点 | 推荐度 |
|------|------|------|--------|
| 手动更新 | 完全控制 | 容易出错，繁琐 | ⭐⭐ |
| 自定义脚本 | 自动化，可定制 | 需要维护 | ⭐⭐⭐⭐ |
| pip-tools | 专业，功能强大 | 学习曲线 | ⭐⭐⭐⭐⭐ |
| poetry | 现代化，全功能 | 改变项目结构 | ⭐⭐⭐⭐ |
| pipenv | 自动锁定 | 性能问题 | ⭐⭐⭐ |

## 最佳实践

### ✅ 推荐做法

1. **使用自动化脚本** - `./scripts/update_deps.sh`
2. **升级前备份** - `pip freeze > requirements.backup`
3. **升级后测试** - 运行 pytest 和应用
4. **小步更新** - 一次升级一个包
5. **记录变化** - 在 git commit 中说明版本号
6. **使用锁定文件** - 生产环境用 requirements.lock

### ❌ 避免做法

1. ❌ 直接 `pip install --upgrade` 不更新配置文件
2. ❌ 升级所有包不测试
3. ❌ 不备份就升级
4. ❌ 忘记更新 requirements.lock
5. ❌ 不提交配置文件更新

## 快速参考

```bash
# 查看当前版本
pip show gradio
pip list | grep gradio

# 升级包（推荐使用脚本）
./scripts/update_deps.sh gradio

# 手动升级
pip install --upgrade gradio
pip show gradio  # 查看新版本
# 编辑 requirements.txt
pip freeze > requirements.lock

# 回滚
pip install -r requirements.backup

# 查看依赖树
pip install pipdeptree
pipdeptree -p gradio

# 检查冲突
pip check
```

## 总结

| 操作 | 命令 | 是否更新配置文件 |
|------|------|-----------------|
| 升级包 | `pip install --upgrade gradio` | ❌ 不会 |
| 查看版本 | `pip show gradio` | - |
| 更新配置 | 手动编辑或使用脚本 | ✅ 需要手动 |
| 生成锁定 | `pip freeze > requirements.lock` | ✅ 会 |

**记住**: `pip install --upgrade` 只升级虚拟环境中的包，**不会**自动更新 requirements.txt 等配置文件！

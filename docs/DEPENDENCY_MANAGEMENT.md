# Python 依赖管理指南

## 查看已安装的包版本

### 查看单个包的版本

```bash
# 详细信息（包括版本、依赖等）
pip show gradio

# 输出示例:
# Name: gradio
# Version: 4.44.0
# Summary: Python library for building machine learning web apps
# ...
```

### 查看所有包的版本

```bash
# 列出所有已安装的包
pip list

# 只查看包含 gradio 的包
pip list | grep gradio

# 输出示例:
# gradio                4.44.0
# gradio-client         1.3.0
```

### 查看精确的依赖树

```bash
# 安装 pipdeptree 工具
pip install pipdeptree

# 查看 gradio 的依赖树
pipdeptree -p gradio

# 输出示例:
# gradio==4.44.0
#   ├── aiofiles [required: >=22.0,<24.0]
#   ├── altair [required: >=4.2.0,<6.0]
#   └── ...
```

## 版本号语法说明

### 常见的版本指定方式

```python
# 1. 精确版本（最严格）
gradio==4.44.0          # 只能是 4.44.0

# 2. 最小版本（推荐开发）
gradio>=4.0.0           # 4.0.0 或更高

# 3. 兼容版本
gradio~=4.44.0          # >=4.44.0, <4.45.0（只允许补丁版本更新）

# 4. 版本范围
gradio>=4.0.0,<5.0.0    # 4.x 系列的任何版本

# 5. 排除特定版本
gradio>=4.0.0,!=4.20.0  # 4.0.0 或更高，但不是 4.20.0
```

### 语义化版本（SemVer）

版本号格式：`主版本.次版本.补丁版本`

```
4.44.0
│ │  │
│ │  └─ 补丁版本（bug 修复）
│ └──── 次版本（新功能，向后兼容）
└────── 主版本（破坏性更改）
```

## 依赖管理策略

### 策略 A: 宽松版本（开发阶段）

**requirements.txt:**
```
gradio>=4.0.0
```

**优点:**
- ✅ 自动获取最新的 bug 修复和安全更新
- ✅ 灵活，适合快速开发

**缺点:**
- ⚠️ 不同人安装可能得到不同版本
- ⚠️ 可能引入不兼容的更新

**适用场景:** 个人项目、快速原型开发

### 策略 B: 锁定版本（生产环境）

**requirements.txt:**
```
gradio==4.44.0
```

**优点:**
- ✅ 所有人安装的版本完全一致
- ✅ 可重现的构建
- ✅ 避免意外的破坏性更新

**缺点:**
- ⚠️ 需要手动更新版本号
- ⚠️ 可能错过安全更新

**适用场景:** 生产环境、团队协作

### 策略 C: 双文件管理（推荐）⭐

**requirements.txt（宽松）:**
```
gradio>=4.0.0
```

**requirements.lock（精确）:**
```
gradio==4.44.0
aiofiles==23.2.1
altair==5.2.0
# ... 所有依赖的精确版本
```

**使用方式:**
```bash
# 开发时使用宽松版本
pip install -r requirements.txt

# 生产环境使用锁定版本
pip install -r requirements.lock

# 更新依赖后重新生成锁定文件
pip freeze > requirements.lock
```

## 实际操作流程

### 1. 安装新包

```bash
# 激活虚拟环境
source venv/bin/activate

# 安装包
pip install gradio

# 或升级到最新版本
pip install --upgrade gradio
```

### 2. 查看安装的版本

```bash
# 查看 gradio 版本
pip show gradio

# 输出:
# Name: gradio
# Version: 4.44.0
```

### 3. 更新 requirements.txt

**方式 1: 手动添加（推荐）**
```bash
# 编辑 requirements.txt，添加:
gradio>=4.44.0
```

**方式 2: 使用 pip freeze（精确版本）**
```bash
# 生成所有包的精确版本
pip freeze > requirements.lock

# 或只添加 gradio
pip freeze | grep gradio >> requirements.txt
```

### 4. 提交到 git

```bash
git add requirements.txt
git commit -m "Add gradio dependency"
git push
```

## 推荐的项目结构

```
gradio-droplet/
├── requirements.txt        # 宽松版本，用于开发
├── requirements-dev.txt    # 开发工具依赖
└── requirements.lock       # 精确版本，用于生产（可选）
```

### requirements.txt（宽松版本）
```
# 生产依赖
gradio>=4.0.0
```

### requirements-dev.txt（开发依赖）
```
-r requirements.txt
pytest>=7.0.0
black>=23.0.0
```

### requirements.lock（精确版本）
```
# 由 pip freeze 生成
gradio==4.44.0
aiofiles==23.2.1
altair==5.2.0
# ... 所有依赖
```

## 常用命令速查

```bash
# 查看包版本
pip show <package>              # 详细信息
pip list                        # 所有包
pip list | grep <package>       # 搜索特定包

# 安装依赖
pip install -r requirements.txt           # 安装依赖
pip install --upgrade <package>           # 升级包
pip install <package>==<version>          # 安装特定版本

# 生成依赖文件
pip freeze                      # 显示所有包的精确版本
pip freeze > requirements.lock  # 保存到文件
pip freeze | grep <package>     # 只显示特定包

# 依赖树
pip install pipdeptree          # 安装工具
pipdeptree                      # 查看依赖树
pipdeptree -p <package>         # 查看特定包的依赖
```

## 升级依赖的最佳实践

### 1. 升级前备份

```bash
# 保存当前版本
pip freeze > requirements.backup

# 升级包
pip install --upgrade gradio

# 如果出问题，回滚
pip install -r requirements.backup
```

### 2. 测试升级

```bash
# 升级包
pip install --upgrade gradio

# 运行测试
pytest

# 运行应用
python examples/app.py

# 如果一切正常，更新 requirements.txt
pip freeze | grep gradio
# 将输出的版本号更新到 requirements.txt
```

### 3. 更新 requirements.lock

```bash
# 升级后重新生成锁定文件
pip freeze > requirements.lock

# 提交更新
git add requirements.txt requirements.lock
git commit -m "Upgrade gradio to 4.44.0"
```

## 常见问题

### Q: pip install --upgrade gradio 后，如何知道安装了哪个版本？

```bash
# 方法 1: 查看详细信息
pip show gradio

# 方法 2: 查看版本号
pip list | grep gradio

# 方法 3: 在 Python 中查看
python -c "import gradio; print(gradio.__version__)"
```

### Q: 如何确保团队成员安装相同的版本？

使用 `requirements.lock`:
```bash
# 生成锁定文件
pip freeze > requirements.lock

# 团队成员安装
pip install -r requirements.lock
```

### Q: 如何只更新 requirements.txt 中的一个包？

```bash
# 1. 升级包
pip install --upgrade gradio

# 2. 查看新版本
pip show gradio

# 3. 手动更新 requirements.txt
# 将 gradio>=4.0.0 改为 gradio>=4.44.0
```

### Q: pip freeze 输出太多，如何只保存项目依赖？

使用 `pipreqs`:
```bash
# 安装 pipreqs
pip install pipreqs

# 自动分析项目代码，生成 requirements.txt
pipreqs . --force

# 只会包含代码中实际使用的包
```

## 总结

| 场景 | 推荐方式 | 示例 |
|------|---------|------|
| 开发阶段 | 宽松版本 | `gradio>=4.0.0` |
| 生产环境 | 精确版本 | `gradio==4.44.0` |
| 查看版本 | `pip show` | `pip show gradio` |
| 锁定版本 | `pip freeze` | `pip freeze > requirements.lock` |
| 升级包 | `pip install --upgrade` | `pip install --upgrade gradio` |

**记住**: 升级包后，使用 `pip show <package>` 查看安装的版本，然后更新 requirements.txt！

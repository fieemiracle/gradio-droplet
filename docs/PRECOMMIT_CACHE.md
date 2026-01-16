# Pre-commit 缓存位置说明

## 问题

你可能注意到 pre-commit 的日志在 `~/.cache/pre-commit/pre-commit.log`，而不是项目目录。

## 这是正常的！

Pre-commit 的缓存**故意**放在用户主目录，这是官方设计，不是错误。

### 缓存位置

```
~/.cache/pre-commit/           # Linux/macOS
%LOCALAPPDATA%\pre-commit\     # Windows
```

### 为什么不在项目目录？

#### 1. 跨项目共享

多个项目可以共享同一个 hook 环境：

```
~/.cache/pre-commit/
├── repo<hash1>/          # black 环境（所有项目共享）
├── repo<hash2>/          # flake8 环境（所有项目共享）
└── repo<hash3>/          # isort 环境（所有项目共享）
```

**好处**:
- 节省磁盘空间
- 加快安装速度（第二个项目不需要重新下载）

#### 2. 避免污染项目

如果缓存在项目目录：

```
gradio-droplet/
├── .pre-commit-cache/    # ❌ 会很大（几百 MB）
│   ├── repo1/
│   ├── repo2/
│   └── repo3/
├── src/
└── tests/
```

**问题**:
- 项目目录变得臃肿
- 需要在 .gitignore 中忽略
- 每个项目都要下载一份

#### 3. 标准做法

这是 pre-commit 的官方设计，遵循 XDG Base Directory 规范：

- **配置**: `~/.config/`
- **缓存**: `~/.cache/`
- **数据**: `~/.local/share/`

## 项目中的 Pre-commit 文件

### 应该提交到 Git 的文件

```
gradio-droplet/
├── .pre-commit-config.yaml   ✅ 提交（配置文件）
└── .gitignore                ✅ 提交（忽略规则）
```

### 不应该提交的文件

```
gradio-droplet/
├── .git/hooks/
│   ├── pre-commit            ❌ 不提交（自动生成）
│   └── commit-msg            ❌ 不提交（自动生成）
└── requirements.backup       ❌ 不提交（临时文件）
```

### 用户主目录的文件（不在项目中）

```
~/.cache/pre-commit/
├── repo<hash>/               ❌ 不在项目中
└── pre-commit.log            ❌ 不在项目中
```

## .gitignore 配置

项目的 `.gitignore` 已经配置好：

```gitignore
# 缓存
.cache                    # 通用缓存目录
.pre-commit-cache/        # 如果有本地缓存

# 临时文件
*.backup                  # 备份文件
requirements.backup       # 依赖备份
*.bak
*.tmp

# 日志
*.log
logs/

# 虚拟环境
.venv/
venv/

# IDE
.vscode/*
!.vscode/settings.json
```

## 如何管理 Pre-commit 缓存

### 查看缓存大小

```bash
du -sh ~/.cache/pre-commit
# 输出: 500M  /Users/didi/.cache/pre-commit
```

### 清理缓存

```bash
# 清理所有项目的缓存
pre-commit clean

# 或手动删除
rm -rf ~/.cache/pre-commit
```

### 清理后会发生什么？

下次运行 pre-commit 时会重新下载和安装 hooks，但不影响项目配置。

## 常见误解

### ❌ 误解 1: 缓存应该在项目中

**错误**: "日志应该在项目目录"

**正确**: Pre-commit 缓存在用户目录是标准做法，类似于：
- npm 缓存: `~/.npm/`
- pip 缓存: `~/.cache/pip/`
- Docker 镜像: `~/.docker/`

### ❌ 误解 2: 需要提交 .git/hooks/

**错误**: "应该提交 .git/hooks/ 到 git"

**正确**: `.git/` 目录永远不提交，hooks 由 `pre-commit install` 自动生成。

### ❌ 误解 3: 每个项目都要重新下载

**错误**: "每个项目都要下载 black, flake8"

**正确**: 第一个项目下载后，其他项目会复用缓存。

## 如果确实想要本地缓存

如果你坚持要在项目中缓存（不推荐），可以设置环境变量：

```bash
# 设置本地缓存目录
export PRE_COMMIT_HOME=./.pre-commit-cache

# 运行 pre-commit
pre-commit install
```

但这样做会：
- ❌ 增加项目大小
- ❌ 需要在 .gitignore 中忽略
- ❌ 无法跨项目共享
- ❌ 团队成员都要设置相同的环境变量

## 团队协作

### 新成员设置

```bash
# 1. 克隆项目
git clone <repo-url>
cd gradio-droplet

# 2. 创建虚拟环境
python3 -m venv .venv
source .venv/bin/activate

# 3. 安装依赖
pip install -r requirements-dev.txt

# 4. 安装 pre-commit hooks
pre-commit install
pre-commit install --hook-type commit-msg

# 5. Pre-commit 会自动在 ~/.cache/pre-commit/ 创建缓存
```

### 不需要同步的内容

- ❌ `~/.cache/pre-commit/` - 每个人自己的缓存
- ❌ `.git/hooks/` - 自动生成
- ❌ `requirements.backup` - 临时文件

### 需要同步的内容

- ✅ `.pre-commit-config.yaml` - 配置文件
- ✅ `.gitignore` - 忽略规则
- ✅ `requirements.txt` - 依赖
- ✅ `pyproject.toml` - 项目配置

## 对比其他工具

| 工具 | 缓存位置 | 原因 |
|------|---------|------|
| pre-commit | `~/.cache/pre-commit/` | 跨项目共享 |
| npm | `~/.npm/` | 跨项目共享 |
| pip | `~/.cache/pip/` | 跨项目共享 |
| Docker | `~/.docker/` | 跨项目共享 |
| Homebrew | `/usr/local/Cellar/` | 系统级共享 |

## 总结

| 问题 | 答案 |
|------|------|
| 缓存在哪里？ | `~/.cache/pre-commit/` |
| 这是错误吗？ | ❌ 不是，这是设计行为 |
| 需要提交吗？ | ❌ 不需要 |
| 需要在 .gitignore 中忽略吗？ | ❌ 不需要（不在项目中） |
| 可以删除吗？ | ✅ 可以，会自动重建 |
| 可以改到项目中吗？ | ⚠️ 可以但不推荐 |

**记住**: Pre-commit 缓存在用户目录是**正常的、推荐的**做法！

## 参考资源

- [Pre-commit 官方文档](https://pre-commit.com/)
- [XDG Base Directory 规范](https://specifications.freedesktop.org/basedir-spec/basedir-spec-latest.html)

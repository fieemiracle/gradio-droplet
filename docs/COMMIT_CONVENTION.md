# Commit 规范指南

本项目使用 [Conventional Commits](https://www.conventionalcommits.org/) 规范。

## Commit 消息格式

```
<type>: <subject>

[optional body]

[optional footer]
```

### 必需部分

- **type**: 提交类型（必需）
- **subject**: 简短描述（必需）

### 示例

```bash
feat: add user authentication
fix: resolve login button crash
docs: update README installation steps
style: format code with black
refactor: simplify database query logic
test: add unit tests for user service
chore: update dependencies
```

## Type 类型说明

| Type | 说明 | 示例 |
|------|------|------|
| `feat` | 新功能 | `feat: add dark mode toggle` |
| `fix` | Bug 修复 | `fix: resolve memory leak in upload` |
| `docs` | 文档更新 | `docs: add API usage examples` |
| `style` | 代码格式（不影响功能） | `style: format with black` |
| `refactor` | 重构（不是新功能或 bug 修复） | `refactor: extract validation logic` |
| `perf` | 性能优化 | `perf: optimize image loading` |
| `test` | 测试相关 | `test: add integration tests` |
| `build` | 构建系统或依赖 | `build: upgrade to Python 3.11` |
| `ci` | CI/CD 配置 | `ci: add GitHub Actions workflow` |
| `chore` | 其他杂项 | `chore: update .gitignore` |
| `revert` | 回滚提交 | `revert: revert feat: add dark mode` |

## Subject 编写规则

### ✅ 推荐

- 使用祈使句，现在时态："add" 而不是 "added" 或 "adds"
- 不要大写首字母
- 不要以句号结尾
- 简洁明了，不超过 50 个字符

```bash
✅ feat: add user profile page
✅ fix: resolve database connection timeout
✅ docs: update installation guide
```

### ❌ 避免

```bash
❌ feat: Added user profile page        # 不要用过去时
❌ fix: Resolve database timeout        # 不要大写首字母
❌ docs: update installation guide.     # 不要句号
❌ feat: add a new feature that allows users to...  # 太长
```

## 完整示例

### 简单提交

```bash
feat: add email validation
```

### 带 body 的提交

```bash
feat: add email validation

Implement email format validation using regex.
Add error messages for invalid email formats.
```

### 带 breaking change 的提交

```bash
feat!: change API response format

BREAKING CHANGE: API now returns data in camelCase instead of snake_case.
Update all API clients accordingly.
```

## 使用 Commitizen 工具

### 安装

```bash
pip install commitizen pre-commit
```

### 交互式创建 commit

```bash
# 使用 commitizen 交互式创建 commit
cz commit

# 或简写
cz c
```

工具会引导你：
1. 选择 type
2. 输入 scope（可选）
3. 输入简短描述
4. 输入详细描述（可选）
5. 是否有 breaking changes
6. 是否关闭 issue

### 检查 commit 消息

```bash
# 检查最近的 commit
cz check --rev-range HEAD

# 检查特定 commit
cz check --commit-msg-file .git/COMMIT_EDITMSG
```

## 使用 Pre-commit Hooks

### 安装 hooks

```bash
# 安装 pre-commit
pip install pre-commit

# 安装 git hooks
pre-commit install
pre-commit install --hook-type commit-msg
```

### 工作流程

安装后，每次 `git commit` 时会自动：

1. **代码检查**：运行 black, flake8, isort
2. **格式化**：自动格式化代码
3. **Commit 消息检查**：验证 commit 消息格式

```bash
# 正常提交
git add .
git commit -m "feat: add new feature"

# 如果格式错误，会被拒绝
git commit -m "added new feature"
# ❌ [commitizen] commit message does not follow format

# 如果代码格式有问题，会自动修复
git commit -m "feat: add new feature"
# black 自动格式化代码
# 需要重新 git add 并提交
```

### 手动运行所有检查

```bash
# 对所有文件运行检查
pre-commit run --all-files

# 只运行特定 hook
pre-commit run black --all-files
pre-commit run commitizen --all-files
```

## 常见场景

### 场景 1: 添加新功能

```bash
git add .
git commit -m "feat: add user registration form"
```

### 场景 2: 修复 Bug

```bash
git add .
git commit -m "fix: resolve login redirect issue"
```

### 场景 3: 更新文档

```bash
git add README.md
git commit -m "docs: add installation instructions"
```

### 场景 4: 更新依赖

```bash
git add requirements.txt requirements.lock
git commit -m "chore: update gradio to 6.5.0"
```

### 场景 5: 代码重构

```bash
git add .
git commit -m "refactor: extract validation logic to separate module"
```

### 场景 6: 多行 commit

```bash
git commit -m "feat: add user authentication

- Implement JWT token generation
- Add login and logout endpoints
- Create user session management
- Add authentication middleware

Closes #123"
```

## 使用 VSCode 扩展

推荐安装 VSCode 扩展：

1. **Conventional Commits** - 提供 commit 消息模板
2. **Git Commit Message Editor** - 可视化编辑 commit 消息

## Commit 消息模板

创建 `.gitmessage` 模板：

```bash
# 设置 commit 模板
git config commit.template .gitmessage
```

`.gitmessage` 内容：

```
# <type>: <subject>
#
# <body>
#
# <footer>

# Type 可选值:
# feat:     新功能
# fix:      Bug 修复
# docs:     文档更新
# style:    代码格式
# refactor: 重构
# perf:     性能优化
# test:     测试
# build:    构建系统
# ci:       CI/CD
# chore:    其他
# revert:   回滚

# Subject 规则:
# - 使用祈使句，现在时态
# - 不要大写首字母
# - 不要以句号结尾
# - 不超过 50 个字符

# Body 规则:
# - 解释"是什么"和"为什么"，而不是"怎么做"
# - 每行不超过 72 个字符

# Footer 规则:
# - 引用 issue: Closes #123, Fixes #456
# - Breaking changes: BREAKING CHANGE: description
```

## 检查历史 commit

```bash
# 查看最近 10 条 commit
git log --oneline -10

# 检查 commit 格式
cz check --rev-range HEAD~10..HEAD

# 生成 changelog
cz changelog
```

## 常见错误和解决方案

### 错误 1: Commit 消息格式不正确

```bash
❌ git commit -m "Added new feature"

✅ git commit -m "feat: add new feature"
```

### 错误 2: Type 拼写错误

```bash
❌ git commit -m "feature: add login"

✅ git commit -m "feat: add login"
```

### 错误 3: Subject 首字母大写

```bash
❌ git commit -m "feat: Add login page"

✅ git commit -m "feat: add login page"
```

### 错误 4: Subject 以句号结尾

```bash
❌ git commit -m "feat: add login page."

✅ git commit -m "feat: add login page"
```

### 错误 5: 缺少冒号和空格

```bash
❌ git commit -m "feat:add login"
❌ git commit -m "feat add login"

✅ git commit -m "feat: add login"
```

## 绕过检查（不推荐）

如果确实需要绕过检查：

```bash
# 绕过 pre-commit hooks
git commit --no-verify -m "emergency fix"

# 但不推荐这样做！
```

## 团队协作

### 新成员设置

```bash
# 1. 克隆项目
git clone <repo-url>
cd gradio-droplet

# 2. 创建虚拟环境
python3 -m venv venv
source venv/bin/activate

# 3. 安装依赖
pip install -r requirements-dev.txt

# 4. 安装 pre-commit hooks
pre-commit install
pre-commit install --hook-type commit-msg

# 5. 测试
pre-commit run --all-files
```

### 统一规范

所有团队成员必须：
1. ✅ 安装 pre-commit hooks
2. ✅ 遵循 commit 规范
3. ✅ 在 PR 前运行 `pre-commit run --all-files`

## 快速参考

```bash
# 安装工具
pip install commitizen pre-commit

# 安装 hooks
pre-commit install
pre-commit install --hook-type commit-msg

# 交互式 commit
cz commit

# 普通 commit（遵循规范）
git commit -m "feat: add new feature"
git commit -m "fix: resolve bug"
git commit -m "docs: update README"

# 检查 commit 格式
cz check --rev-range HEAD

# 运行所有检查
pre-commit run --all-files

# 生成 changelog
cz changelog
```

## 总结

| 操作 | 命令 |
|------|------|
| 交互式创建 commit | `cz commit` |
| 普通 commit | `git commit -m "type: subject"` |
| 检查格式 | `cz check --rev-range HEAD` |
| 安装 hooks | `pre-commit install` |
| 运行检查 | `pre-commit run --all-files` |

**记住**: 所有 commit 必须遵循 `type: subject` 格式！

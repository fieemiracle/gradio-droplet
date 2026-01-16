# Pre-commit 错误修复指南

## 错误信息

```
CalledProcessError: command: ('/path/to/.venv/bin/python3.14', '-mvirtualenv', '/path/to/cache/py_env-python3.10', '-p', 'python3.10')
return code: 1
stdout:
    RuntimeError: failed to find interpreter for Builtin discover of python_spec='python3.10'
```

## 问题原因

`.pre-commit-config.yaml` 中指定了 `language_version: python3.10`，但你的系统使用的是 Python 3.14。

## 解决方案

### 步骤 1: 修复配置文件

`.pre-commit-config.yaml` 已经修复为：

```yaml
- repo: https://github.com/psf/black
  rev: 25.1.0
  hooks:
    - id: black
      language_version: python3  # 使用系统默认 Python 3
```

### 步骤 2: 清理并重新安装

```bash
# 1. 确保在项目根目录
cd /Users/didi/Desktop/Projects/gradio-droplet

# 2. 激活虚拟环境
source .venv/bin/activate

# 3. 安装必要的工具
pip install pre-commit commitizen isort

# 4. 清理 pre-commit 缓存
pre-commit clean

# 5. 卸载旧的 hooks
pre-commit uninstall

# 6. 重新安装 hooks
pre-commit install
pre-commit install --hook-type commit-msg

# 7. 测试配置
pre-commit run --all-files
```

### 步骤 3: 重新提交

```bash
# 1. 查看状态
git status

# 2. 添加修复后的配置文件
git add .pre-commit-config.yaml

# 3. 提交（现在应该可以了）
git commit -m "feat: add commit rule"
```

## 完整操作流程

```bash
# 进入项目目录
cd /Users/didi/Desktop/Projects/gradio-droplet

# 激活虚拟环境
source .venv/bin/activate

# 安装工具
pip install pre-commit commitizen isort

# 清理并重新安装
pre-commit clean
pre-commit uninstall
pre-commit install
pre-commit install --hook-type commit-msg

# 测试
pre-commit run --all-files

# 提交
git add .
git commit -m "feat: add commit rule"
```

## 如果还有问题

### 方法 1: 完全删除 language_version

编辑 `.pre-commit-config.yaml`，删除 `language_version` 行：

```yaml
- repo: https://github.com/psf/black
  rev: 25.1.0
  hooks:
    - id: black
      # 删除 language_version 行
```

### 方法 2: 使用本地 hooks

如果 pre-commit 一直有问题，可以使用本地 hooks：

```yaml
repos:
  - repo: local
    hooks:
      - id: black
        name: black
        entry: black
        language: system
        types: [python]

      - id: flake8
        name: flake8
        entry: flake8
        language: system
        types: [python]
        args: ['--max-line-length=88', '--extend-ignore=E203,W503']

      - id: isort
        name: isort
        entry: isort
        language: system
        types: [python]
        args: ['--profile', 'black']
```

### 方法 3: 临时跳过 pre-commit

如果急需提交：

```bash
# 跳过 pre-commit hooks（不推荐）
git commit --no-verify -m "feat: add commit rule"
```

## 验证修复

```bash
# 1. 检查 pre-commit 是否安装
pre-commit --version

# 2. 检查 hooks 是否安装
ls -la .git/hooks/

# 应该看到:
# pre-commit
# commit-msg

# 3. 手动运行所有检查
pre-commit run --all-files

# 4. 测试 commit 消息检查
echo "feat: test message" | pre-commit run commitizen --hook-stage commit-msg
```

## 常见错误

### 错误 1: command not found: pre-commit

**原因**: 虚拟环境未激活或未安装 pre-commit

**解决**:
```bash
source .venv/bin/activate
pip install pre-commit
```

### 错误 2: python3.10 not found

**原因**: 配置文件指定了不存在的 Python 版本

**解决**: 修改 `.pre-commit-config.yaml`，使用 `python3` 而不是 `python3.10`

### 错误 3: Unstaged files detected

**原因**: 有未暂存的文件

**解决**:
```bash
# 暂存所有文件
git add .

# 或只暂存特定文件
git add file1 file2
```

## 检查清单

- [ ] 虚拟环境已激活
- [ ] 已安装 pre-commit, commitizen, isort
- [ ] `.pre-commit-config.yaml` 使用 `python3` 而不是 `python3.10`
- [ ] 已运行 `pre-commit clean`
- [ ] 已运行 `pre-commit install`
- [ ] 已运行 `pre-commit install --hook-type commit-msg`
- [ ] `pre-commit run --all-files` 通过
- [ ] 所有文件已暂存 (`git add .`)

## 快速参考

```bash
# 安装
pip install pre-commit commitizen isort

# 清理
pre-commit clean

# 安装 hooks
pre-commit install
pre-commit install --hook-type commit-msg

# 测试
pre-commit run --all-files

# 提交
git commit -m "feat: add commit rule"

# 跳过检查（紧急情况）
git commit --no-verify -m "message"
```

## 总结

问题已修复：
1. ✅ `.pre-commit-config.yaml` 改为使用 `python3`
2. ✅ 需要清理缓存并重新安装 hooks
3. ✅ 确保虚拟环境激活并安装了所有工具

按照上面的步骤操作即可解决问题！

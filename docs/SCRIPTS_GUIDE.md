# 脚本使用指南

## update_deps.sh - 依赖更新脚本

### 功能
自动升级 Python 包并更新所有相关配置文件。

### 使用方法

#### 正确的使用方式 ✅

**在项目根目录执行:**
```bash
# 切换到项目根目录
cd /Users/didi/Desktop/Projects/gradio-droplet

# 激活虚拟环境
source .venv/bin/activate

# 执行脚本
bash scripts/update_deps.sh gradio
```

**或者使用相对路径（推荐）:**
```bash
# 在项目根目录
./scripts/update_deps.sh gradio

# 升级其他包
./scripts/update_deps.sh pytest
./scripts/update_deps.sh black
```

#### 错误的使用方式 ❌

```bash
# ❌ 不要在 scripts 目录下执行
cd scripts
sh update_deps.sh gradio  # 会在 scripts/ 目录生成文件

# ❌ 不要使用 sh（应该用 bash）
sh scripts/update_deps.sh  # echo -e 不工作
```

### 脚本做了什么

1. **自动切换到项目根目录** - 无论在哪里执行，都会切换到正确的目录
2. **备份当前依赖** - 生成 `requirements.backup`
3. **升级指定的包** - 使用 `pip install --upgrade`
4. **更新配置文件** - 自动更新 `requirements.txt` 或 `requirements-dev.txt`
5. **重新生成锁定文件** - 更新 `requirements.lock`
6. **运行测试** - 验证更新没有破坏功能
7. **提供回滚选项** - 如果测试失败，可以回滚

### 生成的文件

| 文件 | 位置 | 说明 | 是否提交 |
|------|------|------|---------|
| `requirements.backup` | 项目根目录 | 备份文件 | ❌ 不提交 |
| `requirements.lock` | 项目根目录 | 更新的锁定文件 | ✅ 提交 |
| `requirements.txt` | 项目根目录 | 更新的依赖文件 | ✅ 提交 |
| `requirements-dev.txt` | 项目根目录 | 更新的开发依赖 | ✅ 提交 |

### 完整示例

```bash
# 1. 进入项目目录
cd /Users/didi/Desktop/Projects/gradio-droplet

# 2. 激活虚拟环境
source .venv/bin/activate

# 3. 升级 gradio
./scripts/update_deps.sh gradio

# 输出:
# === 依赖更新脚本 ===
# 项目根目录: /Users/didi/Desktop/Projects/gradio-droplet
#
# 步骤 1/6: 备份当前依赖
# ✓ 已备份到 requirements.backup
#
# 步骤 2/6: 升级 gradio
# ✓ gradio 已升级
#
# 步骤 3/6: 查看新版本
# ✓ gradio 新版本: 6.5.0
#
# 步骤 4/6: 更新 requirements 文件
# ✓ 已更新 requirements.txt
#
# 步骤 5/6: 重新生成 requirements.lock
# ✓ 已更新 requirements.lock
#
# 步骤 6/6: 运行测试
# ✓ 测试通过
#
# === 更新完成 ===

# 4. 检查更新
git diff requirements.txt requirements.lock

# 5. 测试应用
python examples/app.py

# 6. 提交更改
git add requirements.txt requirements.lock
git commit -m "chore: update gradio to 6.5.0"
git push

# 7. 清理备份文件
rm requirements.backup
```

### 常见问题

#### Q: 为什么在 scripts/ 目录下执行会出错？

**A**: 旧版本脚本没有处理工作目录，会在当前目录查找文件和生成文件。新版本已修复，会自动切换到项目根目录。

#### Q: 生成的文件在哪里？

**A**: 所有文件都在**项目根目录**，不在 scripts/ 目录：
```
gradio-droplet/
├── requirements.txt        ← 这里
├── requirements-dev.txt    ← 这里
├── requirements.lock       ← 这里
├── requirements.backup     ← 这里（临时文件）
└── scripts/
    └── update_deps.sh
```

#### Q: 如何清理错误生成的文件？

**A**: 如果在 scripts/ 目录下错误生成了文件：
```bash
# 删除 scripts 目录下的错误文件
rm -f scripts/requirements.backup
rm -f scripts/requirements.lock
rm -f scripts/.coverage
```

#### Q: 测试失败怎么办？

**A**: 脚本会询问是否回滚：
```bash
✗ 测试失败
是否回滚到之前的版本? (y/n)
y  # 输入 y 回滚
```

或手动回滚：
```bash
pip install -r requirements.backup
```

#### Q: 为什么要用 bash 而不是 sh？

**A**: `sh` 不支持 `echo -e`（颜色输出），应该用 `bash`：
```bash
✅ bash scripts/update_deps.sh
❌ sh scripts/update_deps.sh
```

#### Q: 如何升级多个包？

**A**: 一次升级一个包：
```bash
./scripts/update_deps.sh gradio
./scripts/update_deps.sh pytest
./scripts/update_deps.sh black
```

#### Q: 备份文件需要提交吗？

**A**: 不需要。`requirements.backup` 是临时备份文件，完成后可以删除：
```bash
rm requirements.backup
```

### 脚本改进

新版本脚本的改进：

1. ✅ **自动切换目录** - 无论在哪里执行，都会切换到项目根目录
2. ✅ **检查文件存在** - 确保 requirements 文件存在
3. ✅ **跨平台兼容** - 支持 macOS 和 Linux 的 sed 命令
4. ✅ **更好的测试处理** - 没有测试时不会报错
5. ✅ **清晰的输出** - 显示项目根目录和更新的文件
6. ✅ **更好的错误处理** - 提供详细的错误信息

### 其他脚本

#### setup_commit_hooks.sh - Commit 规范设置

```bash
# 在项目根目录执行
./scripts/setup_commit_hooks.sh
```

功能：
- 安装 pre-commit hooks
- 配置 commitizen
- 设置 git commit 模板

## 总结

| 操作 | 命令 |
|------|------|
| 升级依赖 | `./scripts/update_deps.sh <package>` |
| 设置 commit hooks | `./scripts/setup_commit_hooks.sh` |
| 清理备份文件 | `rm requirements.backup` |
| 回滚更新 | `pip install -r requirements.backup` |

**记住**:
- ✅ 在项目根目录执行脚本
- ✅ 使用 `bash` 而不是 `sh`
- ✅ 激活虚拟环境后再执行
- ✅ 完成后删除 `requirements.backup`

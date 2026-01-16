# direnv 使用指南

## 什么是 direnv？

direnv 是一个环境变量管理工具，可以在你进入项目目录时**自动加载环境配置**，离开时自动卸载。

### 主要优势

- ✅ **自动激活虚拟环境**: 进入项目目录自动激活，离开自动退出
- ✅ **无需手动操作**: 不用每次都输入 `source venv/bin/activate`
- ✅ **多项目管理**: 每个项目独立配置，互不干扰
- ✅ **环境变量管理**: 可以设置项目特定的环境变量

## 安装 direnv

### macOS
```bash
brew install direnv
```

### Ubuntu/Debian
```bash
sudo apt install direnv
```

### Fedora
```bash
sudo dnf install direnv
```

### 其他系统
参考官方文档: https://direnv.net/docs/installation.html

## 配置 Shell

安装后需要配置你的 shell，让它能识别 direnv。

### Bash
```bash
echo 'eval "$(direnv hook bash)"' >> ~/.bashrc
source ~/.bashrc
```

### Zsh
```bash
echo 'eval "$(direnv hook zsh)"' >> ~/.zshrc
source ~/.zshrc
```

### Fish
```bash
echo 'direnv hook fish | source' >> ~/.config/fish/config.fish
```

## 在本项目中使用

### 首次设置

```bash
# 1. 进入项目目录
cd /Users/didi/Desktop/Projects/gradio-droplet

# 2. 创建虚拟环境（如果还没创建）
python3 -m venv venv

# 3. 允许 direnv 加载 .envrc 配置
direnv allow
```

你会看到类似这样的输出：
```
direnv: loading ~/Desktop/Projects/gradio-droplet/.envrc
direnv: export +VIRTUAL_ENV ~PATH
```

### 日常使用

配置完成后，direnv 会自动工作：

```bash
# 进入项目目录 - 自动激活虚拟环境
cd /Users/didi/Desktop/Projects/gradio-droplet
# direnv: loading .envrc
# direnv: export +VIRTUAL_ENV ~PATH

# 现在虚拟环境已激活，可以直接使用
python examples/app.py

# 离开项目目录 - 自动退出虚拟环境
cd ~
# direnv: unloading
```

## .envrc 文件说明

项目中的 `.envrc` 文件内容：

```bash
# 自动激活虚拟环境
layout python python3
```

### 这行代码做了什么？

- `layout python python3`: direnv 的内置函数，会：
  1. 查找或创建 Python 虚拟环境
  2. 激活虚拟环境
  3. 设置正确的 PATH 和 VIRTUAL_ENV 环境变量

## 常见问题

### Q: 修改 .envrc 后需要做什么？
**A**: 运行 `direnv allow` 重新加载配置。direnv 会提示你这样做。

### Q: 如何临时禁用 direnv？
**A**: 运行 `direnv deny` 或 `direnv block`

### Q: 如何查看当前环境变量？
**A**: 运行 `direnv status` 查看状态

### Q: direnv 和手动激活冲突吗？
**A**: 不冲突。如果你手动激活了虚拟环境，direnv 会检测到并跳过。

### Q: 可以设置其他环境变量吗？
**A**: 可以！在 `.envrc` 中添加：
```bash
layout python python3

# 设置自定义环境变量
export DATABASE_URL="postgresql://localhost/mydb"
export DEBUG=true
export API_KEY="your-api-key"
```

### Q: .envrc 文件应该提交到 git 吗？
**A**:
- ✅ 提交基础配置（如 `layout python python3`）
- ❌ 不要提交敏感信息（API keys, 密码等）
- 💡 可以创建 `.envrc.local` 存放本地配置（添加到 .gitignore）

## 安全提示

direnv 要求你显式允许（`direnv allow`）每个 `.envrc` 文件，这是为了安全考虑：

- 防止恶意代码自动执行
- 你可以先检查 `.envrc` 内容再决定是否允许
- 每次 `.envrc` 修改后都需要重新允许

## 更多功能

### 加载 .env 文件
```bash
# .envrc
layout python python3
dotenv  # 自动加载 .env 文件
```

### 设置项目特定的 PATH
```bash
# .envrc
layout python python3
PATH_add bin  # 添加项目的 bin 目录到 PATH
```

### 条件配置
```bash
# .envrc
layout python python3

if [ -f .env.local ]; then
  dotenv .env.local
fi
```

## 卸载 direnv

如果不想使用了：

```bash
# 1. 从 shell 配置文件中删除 direnv hook
# 编辑 ~/.bashrc 或 ~/.zshrc，删除 direnv 相关行

# 2. 卸载 direnv
# macOS:
brew uninstall direnv

# Ubuntu/Debian:
sudo apt remove direnv
```

## 参考资源

- 官方网站: https://direnv.net/
- GitHub: https://github.com/direnv/direnv
- 文档: https://direnv.net/docs/

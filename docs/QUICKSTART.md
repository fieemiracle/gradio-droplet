# 快速入门指南

本指南帮助新手从零开始设置和运行 Gradio Droplet 项目。

## 前置要求

- Python 3.10 或更高版本
- 终端/命令行工具

检查 Python 版本：
```bash
python3 --version
```

## 完整步骤

### 方式 A: 使用 direnv（推荐，自动激活）⭐

direnv 可以让你进入项目目录时自动激活虚拟环境，非常方便！

#### 步骤 1: 安装 direnv

```bash
# macOS
brew install direnv

# Ubuntu/Debian
sudo apt install direnv

# 其他系统参考: https://direnv.net/docs/installation.html
```

#### 步骤 2: 配置 shell（只需一次）

```bash
# 如果使用 bash
echo 'eval "$(direnv hook bash)"' >> ~/.bashrc
source ~/.bashrc

# 如果使用 zsh
echo 'eval "$(direnv hook zsh)"' >> ~/.zshrc
source ~/.zshrc
```

#### 步骤 3: 创建虚拟环境并允许 direnv

```bash
# 创建虚拟环境
python3 -m venv venv

# 允许 direnv 加载项目配置
direnv allow
```

#### 步骤 4: 安装依赖

```bash
pip install -r requirements.txt
pip install -r requirements-dev.txt
```

#### 步骤 5: 运行应用

```bash
python examples/app.py
```

**完成！** 以后每次 `cd` 进入项目目录，虚拟环境会自动激活。离开目录时自动退出。

---

### 方式 B: 手动激活虚拟环境

如果不想使用 direnv，可以手动激活虚拟环境。

### 步骤 1: 创建虚拟环境

虚拟环境是什么？就像给这个项目创建一个独立的"房间"，所有依赖包都安装在这个房间里，不会影响其他项目。

```bash
# 在项目根目录执行
python3 -m venv venv
```

这会创建一个名为 `venv` 的文件夹，包含独立的 Python 环境。

### 步骤 2: 激活虚拟环境

**macOS/Linux:**
```bash
source venv/bin/activate
```

**Windows:**
```bash
venv\Scripts\activate
```

**成功标志**: 命令行前面会出现 `(venv)`，表示虚拟环境已激活。

```bash
# 激活前
user@computer:~/gradio-droplet$

# 激活后
(venv) user@computer:~/gradio-droplet$
```

### 步骤 3: 安装依赖

确保虚拟环境已激活（看到 `(venv)` 前缀），然后安装依赖：

```bash
# 安装生产依赖
pip install -r requirements.txt

# 安装开发依赖（包含测试工具等）
pip install -r requirements-dev.txt
```

或者一次性安装所有依赖：
```bash
pip install -e ".[dev]"
```

### 步骤 4: 运行示例应用

```bash
python examples/app.py
```

浏览器会自动打开，或手动访问 http://localhost:7860

### 步骤 5: 退出虚拟环境

完成工作后，可以退出虚拟环境：

```bash
deactivate
```

## 常见问题

### Q: 每次都要激活虚拟环境吗？
**A**: 是的。每次打开新的终端窗口工作时，都需要先激活虚拟环境。

### Q: 如何知道虚拟环境是否激活？
**A**: 看命令行前面是否有 `(venv)` 前缀。

### Q: 虚拟环境文件夹可以删除吗？
**A**: 可以。删除后重新执行步骤 1-3 即可。虚拟环境只是一个文件夹，不影响源代码。

### Q: pip install 很慢怎么办？
**A**: 可以使用国内镜像源：
```bash
pip install -r requirements.txt -i https://pypi.tuna.tsinghua.edu.cn/simple
```

## 完整工作流程示例

```bash
# 1. 进入项目目录
cd /Users/didi/Desktop/Projects/gradio-droplet

# 2. 激活虚拟环境
source venv/bin/activate

# 3. 运行应用
python examples/app.py

# 4. 完成工作后退出
deactivate
```

## 下一步

- 阅读 [README.md](README.md) 了解更多功能
- 查看 [examples/app.py](examples/app.py) 学习如何创建 Gradio 应用
- 运行 `pytest` 执行测试
- 使用 `black .` 格式化代码

## 使用 conda 的替代方案

如果你使用 Anaconda/Miniconda：

```bash
# 创建环境
conda create -n gradio-droplet python=3.10

# 激活环境
conda activate gradio-droplet

# 安装依赖
pip install -r requirements.txt
pip install -r requirements-dev.txt

# 运行应用
python examples/app.py

# 退出环境
conda deactivate
```

## 需要帮助？

- 查看 README.md 中的详细文档
- 检查 requirements-dev.txt 中的工具说明
- 确保 Python 版本 >= 3.10

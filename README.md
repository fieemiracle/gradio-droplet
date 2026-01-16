# Gradio Droplet

A Python package for building Gradio applications.

## 快速开始

### 1. 创建虚拟环境（推荐）

虚拟环境可以为每个项目创建独立的 Python 环境，避免依赖冲突。

#### 什么是虚拟环境？
- 为项目创建**隔离的 Python 环境**
- 每个项目有自己的依赖包，互不干扰
- 避免全局安装包导致的版本冲突

#### 使用 venv（Python 内置，推荐）

```bash
# 创建虚拟环境（只需执行一次）
python3 -m venv venv

# 激活虚拟环境
# macOS/Linux:
source venv/bin/activate

# Windows:
venv\Scripts\activate

# 激活后，命令行前面会显示 (venv)
```

#### 使用 direnv（自动激活，最方便）⭐

direnv 可以在你进入项目目录时**自动激活虚拟环境**，无需手动执行 `source venv/bin/activate`。

**安装 direnv:**

```bash
# macOS
brew install direnv

# Ubuntu/Debian
sudo apt install direnv

# 其他系统参考: https://direnv.net/docs/installation.html
```

**配置 shell（只需执行一次）:**

```bash
# 如果使用 bash，添加到 ~/.bashrc
echo 'eval "$(direnv hook bash)"' >> ~/.bashrc

# 如果使用 zsh，添加到 ~/.zshrc
echo 'eval "$(direnv hook zsh)"' >> ~/.zshrc

# 重新加载配置
source ~/.bashrc  # 或 source ~/.zshrc
```

**使用 direnv:**

```bash
# 1. 创建虚拟环境（只需一次）
python3 -m venv venv

# 2. 允许 direnv 加载配置（只需一次）
direnv allow

# 3. 完成！现在每次 cd 进入项目目录，虚拟环境会自动激活
# 离开项目目录时，虚拟环境会自动退出
```

项目已包含 `.envrc` 配置文件，direnv 会自动识别并激活虚拟环境。

#### 使用 conda（如果你安装了 Anaconda）

```bash
# 创建虚拟环境
conda create -n gradio-droplet python=3.10

# 激活虚拟环境
conda activate gradio-droplet

# 退出虚拟环境
conda deactivate
```

#### 退出虚拟环境

```bash
# venv 方式
deactivate

# conda 方式
conda deactivate
```

### 2. 安装依赖

**重要**: 确保已激活虚拟环境（命令行前有 `(venv)` 或 `(gradio-droplet)`）

## Installation

```bash
pip install -e .
```

For development:

```bash
pip install -e ".[dev]"
```

Or using requirements files:

```bash
pip install -r requirements.txt
pip install -r requirements-dev.txt
```

## Usage

### 运行示例应用

项目包含一个示例 Gradio 应用，演示基本用法：

```bash
# 方式 1: 直接运行
python examples/app.py

# 方式 2: 作为模块运行
python -m examples.app
```

启动后，浏览器会自动打开，或者手动访问：
- 本地访问: http://localhost:7860
- 局域网访问: http://0.0.0.0:7860

### 如何启动 Gradio 应用？

**重要**: Gradio 应用使用 `python app.py` 直接启动，**不需要** uvicorn！

#### Gradio vs uvicorn 的区别

| 特性 | Gradio | uvicorn |
|------|--------|---------|
| 用途 | 机器学习/AI 应用的快速 UI 框架 | ASGI 服务器 |
| 启动方式 | `python app.py` | `uvicorn app:app` |
| 内置服务器 | ✅ 有（自带 Web 服务器） | ❌ 无（本身就是服务器） |
| 适用框架 | Gradio | FastAPI, Starlette 等 |

#### 创建你自己的 Gradio 应用

```python
import gradio as gr

def my_function(input_text):
    return f"你输入了: {input_text}"

# 创建界面
demo = gr.Interface(
    fn=my_function,
    inputs="text",
    outputs="text"
)

# 启动应用
if __name__ == "__main__":
    demo.launch()
```

保存为 `my_app.py`，然后运行：

```bash
python my_app.py
```

### 在代码中使用包

```python
from gradio_droplet import __version__

print(f"Gradio Droplet version: {__version__}")
```

## Development

### 开发工具说明

项目使用了以下开发工具来保证代码质量：

#### pytest - 测试框架
- **作用**: 用于编写和运行单元测试，确保代码功能正确
- **为什么需要**: 自动化测试可以在修改代码后快速验证功能是否正常，避免引入 bug
- **使用**: `pytest` 会自动发现并运行 `tests/` 目录下的测试文件

#### pytest-cov - 测试覆盖率
- **作用**: 检查测试覆盖了多少代码，生成覆盖率报告
- **为什么需要**: 帮助你了解哪些代码没有被测试到，提高测试完整性
- **使用**: 运行 `pytest` 时会自动显示覆盖率百分比

#### black - 代码格式化工具
- **作用**: 自动格式化 Python 代码，统一代码风格（缩进、空格、换行等）
- **为什么需要**: 保持代码风格一致，让代码更易读，团队协作时避免格式冲突
- **使用**: `black .` 会自动格式化所有 Python 文件

#### flake8 - 代码检查工具
- **作用**: 检查代码中的语法错误、潜在问题和不符合 PEP 8 规范的地方
- **为什么需要**: 在运行代码前发现错误，养成良好的编码习惯
- **使用**: `flake8 gradio_droplet tests` 检查指定目录的代码

#### mypy - 静态类型检查
- **作用**: 检查 Python 类型注解是否正确，发现类型相关的错误
- **为什么需要**: 在运行前发现类型错误（如传入错误类型的参数），提高代码可靠性
- **使用**: `mypy gradio_droplet` 检查类型注解

### 常用开发命令

#### 运行测试

```bash
pytest
```

#### 代码格式化

```bash
black .
```

#### 代码检查

```bash
flake8 gradio_droplet tests
```

#### 类型检查

```bash
mypy gradio_droplet
```

#### 一键运行所有检查

```bash
# 格式化代码
black .

# 运行所有检查
flake8 gradio_droplet tests && mypy gradio_droplet && pytest
```

## Project Structure

```
gradio-droplet/
├── gradio_droplet/      # Main package source code
│   └── __init__.py
├── tests/               # Test files
│   ├── __init__.py
│   └── test_basic.py
├── docs/                # Documentation
├── examples/            # Example scripts
├── pyproject.toml       # Project configuration
├── requirements.txt     # Production dependencies
├── requirements-dev.txt # Development dependencies
├── README.md            # This file
└── .gitignore          # Git ignore rules
```

## License

MIT

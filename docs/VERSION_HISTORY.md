# 依赖版本更新记录

## 当前版本 (2026-01-16)

### 生产依赖

| 包名 | 版本 | 说明 |
|------|------|------|
| gradio | 6.3.0 | Gradio Web UI 框架 |

### 开发依赖

| 包名 | 版本 | 说明 |
|------|------|------|
| pytest | 9.0.2 | 测试框架 |
| pytest-cov | 7.0.0 | 测试覆盖率 |
| black | 25.12.0 | 代码格式化 |
| flake8 | 7.3.0 | 代码检查 |
| mypy | 1.19.1 | 类型检查 |

### 主要传递依赖

| 包名 | 版本 | 说明 |
|------|------|------|
| fastapi | 0.128.0 | Gradio 使用的 Web 框架 |
| uvicorn | 0.40.0 | ASGI 服务器 |
| pydantic | 2.12.5 | 数据验证 |
| numpy | 2.4.1 | 数值计算 |
| pandas | 2.3.3 | 数据处理 |
| pillow | 12.1.0 | 图像处理 |

## 文件说明

### requirements.txt
- **用途**: 生产环境依赖
- **版本策略**: 精确版本 (==)
- **内容**: 只包含直接依赖 (gradio)

### requirements-dev.txt
- **用途**: 开发环境依赖
- **版本策略**: 精确版本 (==)
- **内容**: 开发工具 (pytest, black, flake8, mypy)

### requirements.lock
- **用途**: 完整依赖锁定
- **版本策略**: 精确版本 (==)
- **内容**: 所有依赖（包括传递依赖）的精确版本
- **生成方式**: 基于 `pip list` 输出

### pyproject.toml
- **用途**: 项目配置和依赖声明
- **版本策略**: 最小版本 (>=)
- **内容**: 项目元数据和依赖范围

## 使用场景

### 开发环境
```bash
# 使用精确版本
pip install -r requirements.txt
pip install -r requirements-dev.txt
```

### 生产环境
```bash
# 使用完整锁定文件，确保版本一致
pip install -r requirements.lock
```

### 新项目/CI/CD
```bash
# 使用 pyproject.toml
pip install -e ".[dev]"
```

## 版本更新流程

### 1. 升级依赖
```bash
pip install --upgrade gradio
```

### 2. 查看新版本
```bash
pip show gradio
pip list
```

### 3. 更新配置文件
```bash
# 手动更新 requirements.txt
# 手动更新 requirements-dev.txt
# 手动更新 pyproject.toml

# 重新生成 requirements.lock
pip freeze > requirements.lock
```

### 4. 测试
```bash
pytest
python examples/app.py
```

### 5. 提交
```bash
git add requirements*.txt requirements.lock pyproject.toml
git commit -m "Update dependencies: gradio 6.3.0"
git push
```

## 版本兼容性

### Python 版本
- **要求**: Python >= 3.10
- **测试版本**: 3.10, 3.11, 3.12

### 操作系统
- ✅ macOS
- ✅ Linux
- ✅ Windows

## 已知问题

无

## 更新历史

### 2026-01-16
- 初始版本
- gradio: 6.3.0
- pytest: 9.0.2
- black: 25.12.0
- flake8: 7.3.0
- mypy: 1.19.1

## 参考资源

- [Gradio 更新日志](https://github.com/gradio-app/gradio/releases)
- [依赖管理指南](./DEPENDENCY_MANAGEMENT.md)

"""
Gradio 开发服务器 - 支持多应用路由和热更新

启动方式:
    python examples/dev_server.py

访问:
    http://localhost:7860/          - 首页（应用列表）
    http://localhost:7860/app       - app.py
    http://localhost:7860/hello     - hello.py
    http://localhost:7860/demo      - demo.py

特性:
    - 自动发现 examples 目录下的所有 .py 文件
    - 支持热更新（修改文件后刷新页面即可）
    - 统一的路由管理
"""

import importlib
import sys
from pathlib import Path
from typing import Dict, Optional

import gradio as gr
from fastapi import FastAPI
from fastapi.responses import HTMLResponse

# 获取 examples 目录
EXAMPLES_DIR = Path(__file__).parent

# 创建 FastAPI 应用
app = FastAPI(title="Gradio 开发服务器")


def discover_apps() -> Dict[str, str]:
    """自动发现 examples 目录下的所有 Gradio 应用"""
    apps = {}

    for file in EXAMPLES_DIR.glob("*.py"):
        # 跳过特殊文件
        if file.name in ["dev_server.py", "__init__.py"]:
            continue

        route_name = file.stem
        apps[route_name] = str(file)

    return apps


def load_gradio_app(file_path: str) -> Optional[gr.Blocks]:
    """动态加载 Gradio 应用（支持热更新）"""
    try:
        module_name = Path(file_path).stem

        # 重新加载模块（热更新的关键）
        if module_name in sys.modules:
            module = importlib.reload(sys.modules[module_name])
        else:
            # 添加 examples 目录到路径
            if str(EXAMPLES_DIR) not in sys.path:
                sys.path.insert(0, str(EXAMPLES_DIR))
            module = importlib.import_module(module_name)

        # 查找 Gradio 应用对象
        for attr_name in ["demo", "app", "interface", "blocks"]:
            if hasattr(module, attr_name):
                obj = getattr(module, attr_name)
                if isinstance(obj, (gr.Blocks, gr.Interface)):
                    print(f"✓ 加载成功: {module_name}")
                    return obj

        print(f"⚠ 警告: {module_name} 中没有找到 Gradio 应用")
        return None

    except Exception as e:
        print(f"❌ 加载失败 {Path(file_path).name}: {e}")
        return None


@app.get("/", response_class=HTMLResponse)
async def home():
    """首页 - 显示所有可用的应用"""
    apps = discover_apps()

    html = """
    <!DOCTYPE html>
    <html>
    <head>
        <title>Gradio 开发服务器</title>
        <style>
            body {
                font-family: -apple-system, BlinkMacSystemFont,
                             "Segoe UI", Roboto, sans-serif;
                max-width: 800px;
                margin: 50px auto;
                padding: 20px;
                background: #f5f5f5;
            }
            h1 {
                color: #333;
                border-bottom: 3px solid #ff7c00;
                padding-bottom: 10px;
            }
            .app-list {
                background: white;
                border-radius: 8px;
                padding: 20px;
                box-shadow: 0 2px 4px rgba(0,0,0,0.1);
            }
            .app-item {
                padding: 15px;
                margin: 10px 0;
                border-left: 4px solid #ff7c00;
                background: #f9f9f9;
                border-radius: 4px;
            }
            .app-item:hover {
                background: #f0f0f0;
            }
            a {
                color: #ff7c00;
                text-decoration: none;
                font-size: 18px;
                font-weight: 500;
            }
            a:hover {
                text-decoration: underline;
            }
            .file-name {
                color: #666;
                font-size: 14px;
                margin-top: 5px;
            }
            .tip {
                background: #e3f2fd;
                padding: 15px;
                border-radius: 4px;
                margin-top: 20px;
                border-left: 4px solid #2196f3;
            }
        </style>
    </head>
    <body>
        <h1>🚀 Gradio 开发服务器</h1>
        <div class="app-list">
            <h2>可用的应用:</h2>
    """

    if not apps:
        html += "<p>没有找到任何应用</p>"
    else:
        for route_name, file_path in sorted(apps.items()):
            file_name = Path(file_path).name
            html += f"""
            <div class="app-item">
                <a href="/{route_name}" target="_blank">/{route_name}</a>
                <div class="file-name">📄 {file_name}</div>
            </div>
            """

    html += """
        </div>
        <div class="tip">
            <strong>💡 提示:</strong>
            <ul>
                <li>修改文件后刷新页面即可看到更新（热更新）</li>
                <li>新增文件需要重启服务器</li>
                <li>每个应用在独立的路由下运行</li>
            </ul>
        </div>
    </body>
    </html>
    """

    return html


def mount_apps():
    """挂载所有 Gradio 应用到 FastAPI"""
    apps = discover_apps()

    print("\n" + "=" * 60)
    print("🚀 Gradio 开发服务器")
    print("=" * 60)

    if not apps:
        print("❌ 没有找到任何 Gradio 应用")
        print(f"   请在 {EXAMPLES_DIR} 目录下创建 .py 文件")
        return

    print(f"\n📁 发现 {len(apps)} 个应用:")

    for route_name, file_path in sorted(apps.items()):
        file_name = Path(file_path).name
        gradio_app = load_gradio_app(file_path)

        if gradio_app:
            # 挂载到 FastAPI
            gr.mount_gradio_app(
                app=app,
                blocks=gradio_app,
                path=f"/{route_name}",
            )
            print(f"   ✓ /{route_name:<15} -> {file_name}")
        else:
            print(f"   ✗ /{route_name:<15} -> {file_name} (加载失败)")

    print("\n📍 访问地址:")
    print("   首页: http://localhost:7860/")
    for route_name in sorted(apps.keys()):
        print(f"   {route_name}: http://localhost:7860/{route_name}")

    print("\n💡 提示:")
    print("   - 修改文件后刷新页面即可看到更新")
    print("   - 新增文件需要重启服务器")
    print("   - 按 Ctrl+C 停止服务器")
    print("=" * 60 + "\n")


if __name__ == "__main__":
    # 挂载所有应用
    mount_apps()

    # 启动服务器
    import uvicorn

    uvicorn.run(app, host="0.0.0.0", port=7860, log_level="info")

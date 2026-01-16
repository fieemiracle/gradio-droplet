"""
Gradio 应用示例

启动方式：
    python examples/app.py

或者从项目根目录：
    python -m examples.app
"""

import gradio as gr


def greet(name: str, intensity: int = 1) -> str:
    """简单的问候函数"""
    return f"Hello, {name}! " + "🎉" * intensity


# 创建 Gradio 界面
with gr.Blocks() as demo:
    gr.Markdown("# Gradio Droplet 示例应用")
    gr.Markdown("这是一个简单的 Gradio 应用示例")

    with gr.Row():
        with gr.Column():
            name_input = gr.Textbox(
                label="输入你的名字", placeholder="请输入名字...", value="World"
            )
            intensity_slider = gr.Slider(
                minimum=1, maximum=5, value=1, step=1, label="热情程度"
            )
            submit_btn = gr.Button("提交", variant="primary")

        with gr.Column():
            output = gr.Textbox(label="问候语", interactive=False)

    # 绑定事件
    submit_btn.click(fn=greet, inputs=[name_input, intensity_slider], outputs=output)

    # 也可以在输入时实时更新
    name_input.change(fn=greet, inputs=[name_input, intensity_slider], outputs=output)


# 启动应用
if __name__ == "__main__":
    print("\n" + "=" * 60)
    print("🚀 Gradio Droplet 示例应用")
    print("=" * 60)
    print("\n📍 访问地址:")
    print("   本地访问: http://localhost:7860")
    print("   或者:     http://127.0.0.1:7860")
    print("\n💡 提示: 不要使用 http://0.0.0.0:7860")
    print("=" * 60 + "\n")

    demo.launch(
        server_name="0.0.0.0",  # 监听所有网络接口（允许局域网访问）
        server_port=7860,  # 端口号
        share=False,  # 是否创建公共分享链接
        debug=True,  # 开启调试模式
        inbrowser=True,  # 自动在浏览器中打开（会打开正确的 localhost 地址）
    )

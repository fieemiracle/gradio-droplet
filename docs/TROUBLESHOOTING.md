# Gradio 应用故障排查指南

## 常见问题

### 问题 1: 无法访问 http://0.0.0.0:7860

#### 症状
```
该网页无法正常工作
0.0.0.0 目前无法处理此请求
```

#### 原因
`0.0.0.0` 是服务器监听地址，不是浏览器访问地址。

- **0.0.0.0**: 表示"监听所有网络接口"，是服务器配置
- **浏览器**: 需要具体的 IP 地址才能访问

#### 解决方案

**✅ 正确的访问地址:**

```
http://localhost:7860
```

或者：

```
http://127.0.0.1:7860
```

#### 详细说明

```python
# 代码中的配置
demo.launch(
    server_name="0.0.0.0",  # 服务器监听地址（不是访问地址！）
    server_port=7860
)
```

| 地址 | 用途 | 能否在浏览器访问 |
|------|------|-----------------|
| `0.0.0.0` | 服务器监听所有网络接口 | ❌ 不能 |
| `localhost` | 本地访问 | ✅ 可以 |
| `127.0.0.1` | 本地回环地址 | ✅ 可以 |
| `192.168.x.x` | 局域网 IP | ✅ 可以（局域网内） |

### 问题 2: 端口被占用

#### 症状
```
OSError: [Errno 48] Address already in use
```

#### 解决方案

**方法 1: 查找并关闭占用端口的进程**

```bash
# macOS/Linux
lsof -i :7860

# 输出示例:
# COMMAND   PID  USER   FD   TYPE DEVICE SIZE/OFF NODE NAME
# python  12345  user    3u  IPv4  0x...      0t0  TCP *:7860 (LISTEN)

# 关闭进程
kill 12345
```

**方法 2: 使用不同的端口**

```python
demo.launch(
    server_name="0.0.0.0",
    server_port=7861  # 改用其他端口
)
```

**方法 3: 让 Gradio 自动选择端口**

```python
demo.launch(
    server_name="0.0.0.0",
    server_port=None  # 自动选择可用端口
)
```

### 问题 3: 局域网内其他设备无法访问

#### 症状
同一局域网内的其他设备无法访问应用。

#### 解决方案

**1. 确保使用 0.0.0.0 监听**

```python
demo.launch(
    server_name="0.0.0.0",  # 必须是 0.0.0.0，不能是 127.0.0.1
    server_port=7860
)
```

**2. 查找本机 IP 地址**

```bash
# macOS/Linux
ifconfig | grep "inet "

# 或
ipconfig getifaddr en0  # macOS WiFi

# 输出示例: 192.168.1.100
```

**3. 在其他设备上访问**

```
http://192.168.1.100:7860
```

**4. 检查防火墙**

```bash
# macOS - 系统偏好设置 > 安全性与隐私 > 防火墙
# 确保允许 Python 接受传入连接

# Linux - 检查 iptables
sudo iptables -L

# 允许端口
sudo ufw allow 7860
```

### 问题 4: 浏览器自动打开了错误的地址

#### 症状
Gradio 自动打开浏览器，但显示 `0.0.0.0:7860` 无法访问。

#### 解决方案

**方法 1: 禁用自动打开，手动访问**

```python
demo.launch(
    server_name="0.0.0.0",
    server_port=7860,
    inbrowser=False  # 不自动打开浏览器
)
```

然后手动访问 `http://localhost:7860`

**方法 2: 使用 127.0.0.1 监听（只允许本地访问）**

```python
demo.launch(
    server_name="127.0.0.1",  # 只监听本地
    server_port=7860,
    inbrowser=True  # 会打开正确的地址
)
```

### 问题 5: 应用启动缓慢

#### 症状
运行 `python app.py` 后等待很久才启动。

#### 可能原因和解决方案

**1. 首次加载模型**

如果应用使用了机器学习模型，首次加载会较慢。

```python
# 添加加载提示
print("正在加载模型...")
model = load_model()
print("模型加载完成！")
```

**2. 依赖包问题**

```bash
# 检查是否有警告
python app.py 2>&1 | grep -i warning

# 升级 gradio
pip install --upgrade gradio
```

**3. 网络问题**

Gradio 可能尝试连接外部服务。

```python
demo.launch(
    server_name="0.0.0.0",
    server_port=7860,
    share=False,  # 确保不创建公共链接
    enable_queue=False  # 禁用队列（如果不需要）
)
```

### 问题 6: 应用崩溃或无响应

#### 症状
应用启动后点击按钮无响应或崩溃。

#### 调试步骤

**1. 启用调试模式**

```python
demo.launch(
    debug=True  # 显示详细错误信息
)
```

**2. 检查函数错误**

```python
def greet(name: str) -> str:
    try:
        # 你的代码
        return f"Hello, {name}!"
    except Exception as e:
        print(f"错误: {e}")
        import traceback
        traceback.print_exc()
        return f"发生错误: {str(e)}"
```

**3. 查看终端输出**

运行应用时注意终端的错误信息。

### 问题 7: 样式显示异常

#### 症状
界面样式混乱或缺失。

#### 解决方案

**1. 清除浏览器缓存**

- Chrome: `Cmd+Shift+Delete` (macOS) 或 `Ctrl+Shift+Delete` (Windows)
- 选择"缓存的图片和文件"
- 清除数据

**2. 强制刷新**

- `Cmd+Shift+R` (macOS)
- `Ctrl+Shift+R` (Windows)

**3. 升级 Gradio**

```bash
pip install --upgrade gradio
```

### 问题 8: 无法创建公共分享链接

#### 症状
设置 `share=True` 后无法生成公共链接。

#### 解决方案

**1. 检查网络连接**

```bash
# 测试网络
ping gradio.app
```

**2. 使用代理（如果在中国）**

```python
import os
os.environ['HTTP_PROXY'] = 'http://proxy.example.com:8080'
os.environ['HTTPS_PROXY'] = 'http://proxy.example.com:8080'

demo.launch(share=True)
```

**3. 使用替代方案**

- 使用 ngrok
- 使用 localtunnel
- 部署到云服务器

## 网络配置对比

| server_name | 本地访问 | 局域网访问 | 公网访问 | 推荐场景 |
|-------------|---------|-----------|---------|---------|
| `127.0.0.1` | ✅ | ❌ | ❌ | 本地开发 |
| `localhost` | ✅ | ❌ | ❌ | 本地开发 |
| `0.0.0.0` | ✅ | ✅ | ❌ | 局域网演示 |
| `share=True` | ✅ | ✅ | ✅ | 公开分享 |

## 访问地址速查表

### 本地开发（推荐）

```python
demo.launch(
    server_name="127.0.0.1",
    server_port=7860
)
```

访问: `http://localhost:7860`

### 局域网访问

```python
demo.launch(
    server_name="0.0.0.0",
    server_port=7860
)
```

访问:
- 本地: `http://localhost:7860`
- 局域网: `http://192.168.x.x:7860`（替换为你的 IP）

### 公开分享

```python
demo.launch(
    server_name="0.0.0.0",
    server_port=7860,
    share=True  # 生成公共链接
)
```

访问: Gradio 会生成一个 `https://xxx.gradio.live` 链接

## 调试技巧

### 1. 查看详细日志

```python
import logging
logging.basicConfig(level=logging.DEBUG)

demo.launch(debug=True)
```

### 2. 测试网络连接

```bash
# 测试端口是否开放
nc -zv localhost 7860

# 或
telnet localhost 7860

# 或使用 curl
curl http://localhost:7860
```

### 3. 检查进程

```bash
# 查看 Python 进程
ps aux | grep python

# 查看端口占用
lsof -i :7860
netstat -an | grep 7860
```

### 4. 使用不同浏览器

有时是浏览器缓存问题，尝试：
- Chrome 隐身模式
- 其他浏览器（Firefox, Safari）

## 快速参考

```bash
# 启动应用
python examples/app.py

# 正确的访问地址
http://localhost:7860
http://127.0.0.1:7860

# 错误的访问地址
http://0.0.0.0:7860  ❌

# 查找本机 IP（局域网访问）
ipconfig getifaddr en0  # macOS
ifconfig | grep "inet "  # Linux

# 检查端口占用
lsof -i :7860

# 关闭占用端口的进程
kill <PID>
```

## 总结

| 问题 | 解决方案 |
|------|---------|
| 无法访问 0.0.0.0:7860 | 使用 `http://localhost:7860` |
| 端口被占用 | 更换端口或关闭占用进程 |
| 局域网无法访问 | 使用 `server_name="0.0.0.0"` |
| 浏览器打开错误地址 | 设置 `inbrowser=True` 或手动访问 |
| 应用崩溃 | 启用 `debug=True` 查看错误 |

**记住**: `0.0.0.0` 是服务器监听地址，浏览器要访问 `localhost:7860`！

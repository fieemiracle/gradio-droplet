# direnv 工作原理详解

## 为什么是 `layout python python3` 而不是 `source venv/bin/activate`？

这是一个常见的疑问。简单回答：**direnv 的工作方式和普通 shell 脚本不同**。

## direnv 的工作原理

### 普通 shell 脚本的工作方式

当你在终端执行 `source venv/bin/activate` 时：

```bash
# 直接在当前 shell 中执行
$ source venv/bin/activate

# 当前 shell 的环境变量被修改
$ echo $VIRTUAL_ENV
/path/to/venv

$ which python
/path/to/venv/bin/python
```

### direnv 的工作方式

direnv 使用完全不同的机制：

```
1. 你进入目录
   ↓
2. direnv 检测到 .envrc 文件
   ↓
3. direnv 在【子进程】中执行 .envrc
   ↓
4. direnv 捕获环境变量的【变化】
   ↓
5. direnv 将这些变化应用到【当前 shell】
```

**关键点**：`.envrc` 在子进程中运行，不是在你的 shell 中运行！

### 为什么 `source` 不工作？

```bash
# .envrc 文件内容（错误示例）
source venv/bin/activate

# 会发生什么：
# 1. direnv 在子进程中执行这行
# 2. 子进程的环境被修改了
# 3. 但子进程结束后，这些修改丢失了
# 4. 你的 shell 没有任何变化 ❌
```

用图示表示：

```
你的 Shell (父进程)
  ↓ 启动
direnv 子进程
  ↓ 执行
source venv/bin/activate  ← 只影响子进程
  ↓ 子进程结束
环境变量修改丢失 ❌
```

## `layout python` 的魔法

`layout python` 是 direnv 的**内置函数**，专门设计用于处理这个问题。

### 它做了什么？

```bash
# layout python python3 的内部实现（简化版）

# 1. 查找虚拟环境目录
if [ -d "venv" ]; then
    VENV_DIR="venv"
elif [ -d ".venv" ]; then
    VENV_DIR=".venv"
fi

# 2. 设置环境变量（以 direnv 兼容的方式）
export VIRTUAL_ENV="$PWD/$VENV_DIR"
PATH_add "$VIRTUAL_ENV/bin"

# 3. 这些 export 和 PATH_add 是 direnv 的特殊函数
# 它们会被 direnv 捕获并应用到父 shell
```

### 关键区别

| 方式 | 执行位置 | 效果传递 | 结果 |
|------|---------|---------|------|
| `source venv/bin/activate` | 子进程 | ❌ 不传递 | 失败 |
| `layout python python3` | 子进程 | ✅ 通过 direnv 传递 | 成功 |

## 实际对比

### 错误方式（不工作）

```bash
# .envrc
source venv/bin/activate
```

```bash
$ cd project
direnv: loading .envrc
$ echo $VIRTUAL_ENV
# 空的！没有激活 ❌
```

### 正确方式（工作）

```bash
# .envrc
layout python python3
```

```bash
$ cd project
direnv: loading .envrc
direnv: export +VIRTUAL_ENV ~PATH
$ echo $VIRTUAL_ENV
/Users/didi/Desktop/Projects/gradio-droplet/venv ✅
$ which python
/Users/didi/Desktop/Projects/gradio-droplet/venv/bin/python ✅
```

## `layout python python3` 的参数说明

```bash
layout python python3
#      ↑      ↑
#      |      └─ 使用哪个 Python 解释器
#      └──────── direnv 的内置函数
```

### 参数的作用

- **`python3`**: 指定 Python 解释器
  - 如果虚拟环境已存在：激活它
  - 如果虚拟环境不存在：使用 `python3` 创建它

### 其他可选参数

```bash
# 使用系统的 python3
layout python python3

# 使用特定版本
layout python python3.10

# 使用特定路径的 Python
layout python /usr/local/bin/python3.11
```

## direnv 的环境变量导出机制

direnv 提供了特殊的函数来导出环境变量：

```bash
# .envrc 中可用的 direnv 函数

# 1. 导出环境变量
export MY_VAR="value"

# 2. 添加到 PATH（前面）
PATH_add bin

# 3. 添加到 PATH（后面）
path_add bin

# 4. 加载 .env 文件
dotenv

# 5. 使用 Python 虚拟环境
layout python python3

# 6. 加载其他 .envrc
source_env ../common.envrc
```

这些函数的特殊之处：
- ✅ 它们的效果会被 direnv 捕获
- ✅ 并应用到父 shell
- ✅ 离开目录时自动撤销

## 技术细节：direnv 如何捕获变化

```bash
# direnv 的工作流程（简化）

# 1. 记录执行前的环境
before_env = capture_environment()

# 2. 执行 .envrc
run_envrc_in_subprocess()

# 3. 记录执行后的环境
after_env = capture_environment()

# 4. 计算差异
diff = after_env - before_env

# 5. 生成 shell 命令应用差异
generate_shell_commands(diff)
# 例如：export VIRTUAL_ENV="/path/to/venv"
#      export PATH="/path/to/venv/bin:$PATH"

# 6. 在父 shell 中执行这些命令
apply_to_parent_shell()
```

## 总结

| 问题 | 答案 |
|------|------|
| 为什么不用 `source`？ | 因为 `.envrc` 在子进程中运行，`source` 的效果不会传递到父 shell |
| `layout python` 是什么？ | direnv 的内置函数，专门用于激活 Python 虚拟环境 |
| 它如何工作？ | 通过 direnv 的特殊机制导出环境变量，效果会应用到父 shell |
| 为什么需要 `python3` 参数？ | 指定使用哪个 Python 解释器来创建/激活虚拟环境 |

## 类比理解

想象 direnv 是一个"环境变量快递员"：

- **普通方式** (`source`)：你在房间里（子进程）装修，但装修效果出不来
- **direnv 方式** (`layout python`)：你告诉快递员要改什么，快递员帮你在外面（父 shell）改好

## 参考资源

- direnv stdlib 文档: https://direnv.net/man/direnv-stdlib.1.html
- layout python 源码: https://github.com/direnv/direnv/blob/master/stdlib.sh

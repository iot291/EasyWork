# 🚀 AI Chat App - 基于 Flutter 的智能聊天助手
> ✨ **一款可自定义 API、主题颜色的 AI 聊天助手，支持 OpenAI 和阿里云 DashScope API**  

---

## 为什么要做这个？

工作中每次需要打开网页的ai工具问些很简单的问题就感觉很麻烦，不停的切窗口。有了这个可以置顶的小窗ai工具，就能随时随地随便问这些简单问题了！

---
## 📌 介绍
**AI Chat App** 是一个 **Flutter 桌面应用**，支持 **Windows**，可以连接 **OpenAI / 阿里云 DashScope** API 进行聊天。它允许用户 **自定义 API Key、API URL 和模型**，并且支持 **更改主题颜色**（包括背景色、聊天气泡等）。  

✅ **支持 OpenAI / 阿里云 API**  
✅ **窗口置顶 / 清空聊天记录**  
✅ **支持 RGB 颜色自定义主题**  
✅ **用户 API 设置可保存，下次自动加载**  
✅ **可拖动鼠标选择聊天文本进行复制**  
✅ **支持 EXE 发行，带有自定义应用图标和标题**  

---

## 🎨 主要功能
### 1️⃣ 支持 OpenAI / 阿里云 API
- 可自由切换 **OpenAI API (`gpt-3.5-turbo`, `gpt-4`)** 或 **阿里云 DashScope (`qwen-plus`)**
- **用户可手动输入 API Key / URL / 模型**
- **输入的 API Key 会缓存**，下次启动时自动加载

### 2️⃣ 可自定义主题颜色
- **深色模式 / 浅色模式**
- **RGB 颜色调节**（支持背景色、用户气泡、AI 气泡）
- **颜色实时更新**

### 3️⃣ 窗口管理
- **支持窗口置顶**（📌 一键置顶）
- **清空聊天记录**
- **窗口默认大小为 `350 x 450`，可调整**

### 4️⃣ 可复制聊天内容
- **鼠标选中聊天记录后，可复制内容**
- **支持 `SelectableText`，方便复制文本**

---

## 📥 下载 & 运行
### 💻 方式 1：从 GitHub 下载 EXE
1. **访问 [GitHub Releases](https://github.com/iot291/EasyWork/releases)**
2. 下载最新的 `release`版本
3. 运行 **`ezflutter.exe`**

### 🛠 方式 2：手动运行 Flutter 代码
**⚠️ 需安装 Flutter SDK**
```sh
git clone https://github.com/iot291/EasyWork.git
cd 你的仓库
flutter pub get
flutter run
```

---

## 🛠 构建 EXE
1. **生成 Windows 可执行文件**
   ```sh
   flutter build windows
   ```
2. **找到 EXE**
   ```
   build\windows\runner\Release\ezflutter.exe
   ```
3. **可选：创建安装程序**
   - 使用 **Inno Setup** 生成 `MyChatAI_Installer.exe`

---

## 📸 截图
| 🎨 深色模式  | 🎨 RGB 自定义颜色 | 📌 窗口置顶 |
|-------------|----------------|------------|
| ![image](https://github.com/user-attachments/assets/b2295733-b602-437f-9cac-98d1a1f39227) | ![image](https://github.com/user-attachments/assets/58d70438-98c5-4b84-8834-9d020070d10a) | ![image](https://github.com/user-attachments/assets/c6242004-e2fe-4978-aad4-5e1f3b02badf) |

---

## 💡 未来改进
✅ **增加流式输出**  
✅ **更多有用的小工具**  
✅ **更加轻量化和人性化设计**  

---

### 🚀 开始使用吧！🎉
🔗 **GitHub Repo**：[你的仓库地址](https://github.com/iot291/EasyWork)  
📢 **如果觉得不错，请点个 ⭐Star 哦！**  

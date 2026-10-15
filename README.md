# TD-MapForge

[English below](#english)

一个像原生 TOP 一样使用的 TouchDesigner 贴图生成插件：接入任意图片 / 视频 / 摄像头 TOP，一次产出**深度图、灰度图、高度图、法线图、置换图**——5 路独立输出端常开，另有 1 路主输出跟随参数面板选中的图，一个实例即可同时喂给下游多个节点。

## 功能（当前状态：M1+M2 已完成）

- **双引擎**：AI 真深度（Depth Anything V2，线程化推理）/ Classic 纯 GPU 近似（无外部依赖，任意支持 GLSL TOP 的 TD 版本可跑）；Auto 档在 AI 未就绪时自动回退 Classic
- **单 `.tox` Base COMP**，TOP 进 TOP 出，拖入即用；输出分辨率跟随源
- 每路输出独立开关：关闭 = 黑帧且该链不 cook，零开销
- AI 链：推理分辨率档位（518/756/1036）、跳帧复用（Skip Frames）、GLSL 联合双边上采样（原图引导保边缘）、输入断开自动清黑
- 失败路径可视化：状态行给出原因，Auto 档自动回退，不静默黑图

## 兼容性

- 实测 **TouchDesigner 2025.31550**（macOS，x86_64/Rosetta）；Classic 引擎无依赖、旧版 TD 可用（未逐版本实测）
- AI 引擎需要 Python 依赖（torch + transformers），安装见下；arm64 原生 TD（MPS 加速）尚未实测，在路线图上（M4）

## 安装

1. 把 `plugin/TD-MapForge.tox` 拖进你的工程（或以 External tox 引用）。
2. （可选，启用 AI 引擎）在 tox 同级目录安装 Python 依赖（约 880MB）：
   - macOS：运行 `plugin/install_ai_deps_mac.sh`（自动定位 tox 同级目录）；或手动执行：
     ```
     arch -x86_64 /Applications/TouchDesigner.app/Contents/Frameworks/Python.framework/Versions/3.11/bin/python3.11 \
       -m pip install --target "<tox同级目录>/TD-MapForge-python" \
       torch==2.2.2 torchvision==0.17.2 transformers==4.46.3
     ```
   - Windows / Linux：用 TD 内置 Python 执行等价 `pip install --target`（torch 按平台自选 CPU/CUDA 轮子）
3. 在插件 Engine 参数页点 **Load Model**：首次自动从 Hugging Face 下载 Depth Anything V2 Small（Apache-2.0，可商用）到 `<tox同级>/TD-MapForge-models/`，加载完自动启用。
4. 高级：**Custom Model Path** 可指向自行放置的更大 DAv2 模型（注意：Small 以上为 CC BY-NC 非商用许可，插件不附带，责任自负）。

## 使用

任意 TOP 接入输入端即可。**Main Output** 菜单选择主输出图（depth/gray/height/normal/disp）；5 路独立输出端同时常开。实时演出建议 Skip Frames 2–4（推理结果复用，主线程不掉帧）；离线出图用 Skip Frames 1 + 更高推理分辨率。

## 路线图

- **M3** 扩展贴图：AO / 曲率 / 深度边缘 / 伪彩色 / 2.5D 视差 / 深度切片 + 视频时域去闪
- **M4** 自绘预览面板 + 性能专项（arm64 原生 / MPS / 性能预算回填）
- **M5** 打磨与发布工程

设计与验收细节见 `docs/TD-MapForge-开发指导.md`。

## 许可

代码 **MIT**（见 `LICENSE`）。模型权重：Depth Anything V2 Small 为 Apache-2.0；更大模型为非商用许可（CC BY-NC），由使用者自负。

---

## English

A TouchDesigner map-generation plugin that behaves like a native TOP: feed it any image / video / camera TOP and get **depth, grayscale, height, normal and displacement maps** in one pass — five always-on independent outputs, plus one main output that follows the map selected on the parameter panel, so a single instance can feed multiple downstream nodes at once.

### Features (current state: M1+M2 complete)

- **Dual engine**: true AI depth (Depth Anything V2, threaded inference) / Classic pure-GPU approximation (no external dependencies, runs on any TD build with GLSL TOPs); Auto mode falls back to Classic whenever AI is not ready
- **Single `.tox` Base COMP**, TOP in / TOP out, drop-in ready; output resolution follows the source
- Per-output enable toggles: off = black frame and the chain does not cook (zero cost)
- AI chain: inference-resolution presets (518/756/1036), frame skipping with result reuse, GLSL joint-bilateral upsampling (source-guided, edge-preserving), automatic black-out when the input disconnects
- Visible failure paths: status line with the actual reason, automatic fallback in Auto mode — never a silent black frame

### Compatibility

- Tested on **TouchDesigner 2025.31550** (macOS, x86_64/Rosetta); the Classic engine is dependency-free and should run on legacy TD builds (not exhaustively tested per version)
- The AI engine needs Python dependencies (torch + transformers, see below); native arm64 TD (MPS acceleration) is untested and on the roadmap (M4)

### Installation

1. Drop `plugin/TD-MapForge.tox` into your project (or reference it as an External tox).
2. (Optional, enables the AI engine) Install the Python dependencies next to the tox (~880MB):
   - macOS: run `plugin/install_ai_deps_mac.sh` (auto-locates the tox sibling directory), or manually:
     ```
     arch -x86_64 /Applications/TouchDesigner.app/Contents/Frameworks/Python.framework/Versions/3.11/bin/python3.11 \
       -m pip install --target "<tox sibling dir>/TD-MapForge-python" \
       torch==2.2.2 torchvision==0.17.2 transformers==4.46.3
     ```
   - Windows / Linux: run the equivalent `pip install --target` with TD's bundled Python (pick the CPU/CUDA torch wheel for your platform)
3. Click **Load Model** on the plugin's Engine page: the first run downloads Depth Anything V2 Small (Apache-2.0, commercial use OK) from Hugging Face into `<tox sibling dir>/TD-MapForge-models/` and enables itself when ready.
4. Advanced: **Custom Model Path** accepts a self-hosted larger DAv2 model (note: beyond Small, weights are CC BY-NC non-commercial — not bundled, your own responsibility).

### Usage

Connect any TOP to the input. The **Main Output** menu selects the main-output map (depth/gray/height/normal/disp); the five dedicated outputs stay live simultaneously. For live shows use Skip Frames 2–4 (results are reused, the main thread keeps its frame rate); for offline quality use Skip Frames 1 and a higher inference resolution.

### Roadmap

- **M3** more maps: AO / curvature / depth edges / pseudocolor / 2.5D parallax / depth slicing + temporal de-flicker for video
- **M4** custom preview panel + performance pass (native arm64 / MPS / measured budgets)
- **M5** polish and release engineering

Design and acceptance details: `docs/TD-MapForge-开发指导.md` (Chinese).

### License

Code: **MIT** (see `LICENSE`). Model weights: Depth Anything V2 Small is Apache-2.0; larger variants are CC BY-NC (non-commercial) — not bundled, use at your own responsibility.

---
name: generate-group-meeting-ppt
description: 生成组会/文献精读汇报学术 PPT：读取 Obsidian 精读笔记或 Zotero 论文，提取论文原图，按规范学术语组稿，经 academic-ppt-master 流程导出可编辑 PPTX。适用于"生成组会汇报PPT / 组会PPT / 论文精读汇报PPT / 文献汇报PPT"。不适用于答辩或开题专用 PPT、Word 报告、纯文献检索。
---

# 生成组会汇报 PPT

## 定位

本技能是**既有技能的编排与约束层**，不重复实现排版引擎：

- 精读与笔记：`obsidian-paper-reading`（笔记不存在时先精读；其 MinerU 脚本已内置 data 解包与 OSS 上传修复）
- 来源查证与 PDF 附件：Zotero 插件技能
- 设计 / SVG 生成 / 导出：`academic-ppt-master`（主链路）
- 学术语域：`research-writing-skill` 及其 `references/academic-presentation-language.md`

执行前按需完整读取上述技能的 `SKILL.md`。本技能只补充组会汇报场景的默认值、顺序与返工规避，不覆盖它们。

## 本机既定环境（默认值，可询问修改）

- Obsidian vault：`D:\obsidian\obsidian仓库\obsidian仓库`；精读笔记目录：`<vault>\文献精读\`
- 组内汇报内容框架参考（仅章节结构，不套排版）：X³ Lab 论文解读模板
- 成品默认输出：`D:\组会报告\`（中文文件名：`主题_组会汇报_姓名_日期.pptx`）
- 演讲稿默认输出：`D:\组会演讲稿\`（中文文件名：`主题_组会演讲稿_姓名_时长.docx`，同时给 Markdown 版本）
- 运行环境：workspace dependencies 提供的 Python 与 Poppler（`native\poppler\Library\bin\pdftoppm.exe`）
- 环境限制：无 flask 则跳过 live preview；无 LibreOffice 则不做 soffice 视觉渲染
- 跨目录写入（vault、D 盘、技能目录）必须先 `request_permissions`

## 工作流（6 步）

### 1. 输入确认（一次）

问清或采用默认：报告人姓名、内容源（vault 笔记或 Zotero key）、输出目录、图片策略（默认：论文原图）、页数（24–30）。**姓名、数据、图表内容不得臆造**；未提供姓名时标注占位并询问。

### 2. 源内容与素材

- 笔记已在 vault 则直接读取；只有论文 PDF 则先按 `obsidian-paper-reading` 生成精读笔记。
- 用 X³ 内容框架确定章节顺序：基础信息 → 背景 → 进展 → 科学问题 → 思路 → 总体架构与分模块 → 对比方法 → 实验设置 → 结果 → 讨论 → 局限与未来 → 文献。
- 论文原图提取与核验见 [references/pitfalls.md](references/pitfalls.md) §2。

### 3. 学术组稿（先文案、后排版）

- 全部页面标题与要点**先按学术书面语定稿**（见 [references/deck-language-register.md](references/deck-language-register.md)），确认无口语后再进入设计阶段——不要生成后再批量返工。
- 按 `academic-ppt-master` 走 init → spec（八项确认给出推荐，等待一次确认；用户要求细化时走 refine-spec 停点）→ 公式 manifest（mixed）→ 图片元数据。

### 4. 生成

- 跟随 `academic-ppt-master` Executor：逐页手写 SVG、每页重读 `spec_lock.md`、只用锁定颜色/字体/图标/图片。
- 生成完先做一轮语言红线扫描（口语词表），再进入质检。

### 5. 质检与导出

- `svg_quality_checker.py`：0 error 才能继续；warning 能修则修。
- `formula_audit.py`：mixed 策略下简单行内符号（θ、∞、O(m·N_ik)、rank < 3+N_c 等）属于合法可编辑文本，运行加 `--warn-only` 并在设计稿注明公式策略；复杂分式/矩阵/上下标表达式必须用 `latex_render.py` 渲染 PNG。
- 依次运行 `finalize_svg.py` → `svg_to_pptx.py` → 复制成品到输出目录。
- 交付前抽检：页数、演讲备注数、封面姓名、关键数字（Table 数值与论文一致）、无遗留占位。

### 6. 清理与留档

- 删除 work 派生物（backup、svg_final、旧导出、渲染页 PNG、traineddata、pycache、OCR 脚本与输出）。
- 保留工程源（`svg_output/ images/ notes/ design_spec.md spec_lock.md`）以便用户微调后重新导出。

## 硬约束（返工高发点）

- **封面版式默认规范（连续两次返工教训）**：封面不使用左上角竖向装饰条，也不做大片顶部留白；1280×720 画布下主标题建议置于 y ≈ 200–260 区段，副题/作者/日期按紧凑垂直节奏排列，底部来源行收尾。生成后按此自检。
- SVG/XML：`font-family` 属性统一 `font-family='"Microsoft YaHei", "PingFang SC", Arial, sans-serif'`（外层单引号、字体名双引号，混用会 XML 非法）；文本用原始 Unicode，禁止 HTML 实体、`rgba()`、`foreignObject`、`mask`；任何修改后必须重跑 checker。
- 数字与术语：表格以论文原文数值重绘并标注来源；`n=∞` 易被误读为 8；原文表头笔误（如 [38]/[39] 实为 [30]/[31]）在页面上注明，不与参考文献表冲突。
- 图片：论文原图一律 `no-crop`（`preserveAspectRatio="xMidYMid meet"`），且**图框尺寸必须按图片原始宽高比反算**（图框 = 图片 + 12px 内边距）；扁框塞竖图会把原图压到看不清。框架/大纲页默认用 2×3 模块卡片，不用方框 + 箭头流程图（详见 references/pitfalls.md §13）。
- 语言：页面文字为书面学术语；演讲备注为口播稿，可保持自然口语。
- 用户说“扩展/丰富 PPT 内容”时先确认是**改页面文字**还是**加演讲者备注**（实测因理解偏差整轮返工）；实验/结果页固定用“实验设计 / 为什么这样设计 / 结果与效果”三段式，建模页固定用“为什么做 / 怎么做 / 结论与边界”逻辑页；用户手工改过的 PPTX 必须先用逐页文本 diff 定位其改动、回写工程源，导出后再 diff 一次确认 0 差异（详见 references/pitfalls.md §15）。
- 演讲稿：先与用户商定时长与内容重心再动笔（默认 10 分钟、正文 2200-2400 字、方案与建模合计约 6 分钟），
  背景知识降为备用材料；交付前按字数控时，超时/欠时的删补方案各给一条（详见 references/pitfalls.md §12）。
- 写入工作区外目录（vault / D 盘输出 / 技能目录）前先检查目录 Owner 是否为登录用户；若为 `CodexSandboxOffline` 或 SYSTEM，先按 references/pitfalls.md §11 修复所有权，否则授权刷新会拖垮执行助手。

## References

- [references/pitfalls.md](references/pitfalls.md)：本机实测的弯路与规避（素材提取、SVG 引号、质检、权限、清理）。
- [references/deck-language-register.md](references/deck-language-register.md)：汇报文案学术语域速查与检查清单。

# generate-group-meeting-ppt

生成组会 / 文献精读汇报学术 PPT 的 Codex 技能：读取 Obsidian 精读笔记或 Zotero 原文，按原始分辨率提取论文原图，用统一版式系统组稿，经 SVG → PPTX 流程导出**可编辑**的演示文稿，并可另出配套演讲稿。

An agent skill for turning papers into editable, well-typeset group-meeting / journal-club decks.

## 能力范围

- **来源**：Obsidian 精读笔记、Zotero 条目与附件 PDF、用户直接提供的论文文件
- **原图**：按 PDF 内嵌位图的**原始分辨率**提取（Flate 位图按 Width/Height 重建、JPEG 直接解容器），不裁切、不臆造
- **版式**：全片统一的版式系统（页眉页脚基线、双栏 560+40+560、三栏 360×3、图框＝图片+12px 内边距）
- **页面骨架**：证据页（双图+三栏要点）、通栏图页、左右分栏页、纯文本页；实验页用「实验设计 / 为什么这样设计 / 结果与效果」，建模页用「为什么做 / 怎么做 / 结论与边界」
- **产出**：可编辑 PPTX（原生形状与文本）＋ 可选的 10 分钟演讲稿（Markdown + DOCX）

**不适用**：答辩 / 开题专用 PPT、Word 报告、纯文献检索。

## 安装

把本目录放到 Codex 的 skills 目录下：

```bash
# Windows
xcopy /E /I generate-group-meeting-ppt "%USERPROFILE%\.codex\skills\generate-group-meeting-ppt"

# macOS / Linux
cp -r generate-group-meeting-ppt ~/.codex/skills/
```

## 发布到 GitHub

本目录已初始化为 git 仓库。在 GitHub 上新建一个空仓库后，在本目录执行：

```powershell
.\publish.ps1 -Owner <你的GitHub用户名>
```

脚本会自动设置 remote 并推送；提示登录时，用户名填 GitHub 用户名，密码处粘贴
Personal Access Token（需要 `repo` 权限，或细粒度 token 勾选 `Contents: Read and write`）。

## 依赖技能

本技能是**编排层**，实际能力来自以下技能，请一并安装：

| 环节 | 技能 |
| --- | --- |
| 设计 / SVG 生成 / 导出 PPTX | `academic-ppt-master` |
| 论文精读与笔记 | `obsidian-paper-reading` |
| Zotero 检索与附件定位 | `zotero` |
| 学术语域与措辞 | `research-writing-skill` |

## 工作流

1. **输入确认**：报告人、内容源、输出目录、图片策略、页数
2. **源内容与素材**：读笔记 / 论文，按原始分辨率提取论文原图
3. **学术组稿**：先定文案（书面学术语），再进设计
4. **生成**：逐页手写 SVG，遵循统一版式系统
5. **质检与导出**：`svg_quality_checker` → `formula_audit` → `finalize_svg` → `svg_to_pptx`
6. **清理与留档**：删除派生物，保留 `svg_output/ images/ notes/ design_spec.md spec_lock.md`

## 经验库

`references/pitfalls.md` 收录了本机实测的弯路与规避规则，按主题编号：

| 编号 | 主题 |
| --- | --- |
| §1–§3 | Zotero 取文、论文原图提取、MinerU 备用路径 |
| §4–§8 | 写入脚本、SVG/XML 引号、质检、环境、权限与清理 |
| §9–§10 | 语言返工教训、封面版式默认规范 |
| §11 | 沙箱授权写入失败（目录所有权问题） |
| §12 | 演讲稿生成：先定时长与内容重心 |
| §13 | 论文原图被压小 / 框架页用流程图 |
| §14 | 逐页返工 → 全片统一版式系统 |
| §15 | 页面内容 vs 演讲备注、用户改稿后的续改 |

`references/deck-language-register.md` 是汇报文案的学术语域速查表。

## 目录结构

```
generate-group-meeting-ppt/
├── SKILL.md                          # 技能说明与硬约束
├── README.md
├── agents/openai.yaml
└── references/
    ├── deck-language-register.md     # 学术语域速查
    └── pitfalls.md                   # 实测弯路与规避
```

## 许可

MIT License，见 [LICENSE](LICENSE)。

# 高等统计学中文学习笔记

[![Build PDF](https://github.com/Studyer-Tang/advanced-mathematical-statistics-notes/actions/workflows/build-pdf.yml/badge.svg)](https://github.com/Studyer-Tang/advanced-mathematical-statistics-notes/actions/workflows/build-pdf.yml)

从概率极限到估计与检验的课程笔记。定义之后给出证明和算例，较容易遗漏的假设写在使用处；多次讨论同一问题时，合并成一条完整推导。

**[阅读合订本](output/pdf/complete-cn.pdf)** · [推导索引](notes/REVIEW.md) · [整理范围](PROGRESS.md) · [勘误](ERRATA.md)

| 章节 | 内容 | 阅读 | 源码 |
| --- | --- | --- | --- |
| 第一章 | 经验分布、随机阶、连续映射、Slutsky 与 Delta 方法 | [PDF](output/pdf/chapter-01-cn.pdf) | [LaTeX](notes/chapter01/chapter01.tex) |
| 第二章 | 指数族、充分性、最小充分性、完备性与 Basu 定理 | [PDF](output/pdf/chapter-02-cn.pdf) | [LaTeX](notes/chapter02/chapter02.tex) |
| 第三章 | 风险、无偏与一致性、Fisher 信息、参数变换与 CR 下界 | [PDF](output/pdf/chapter-03-cn.pdf) | [LaTeX](notes/chapter03/chapter03.tex) |
| 第四章 | UMVUE、Rao–Blackwell、Lehmann–Scheffé、U 统计量及退化极限 | [PDF](output/pdf/chapter-04-cn.pdf) | [LaTeX](notes/chapter04/chapter04.tex) |
| 第五章 | p 值、NP、MLR、UMP、UMPU、条件检验与置信集合 | [PDF](output/pdf/chapter-05-cn.pdf) | [LaTeX](notes/chapter05/chapter05.tex) |
| 附录 A | 第一次作业已讨论的第 7–12 题 | 合订本 | [LaTeX](notes/exercises/homework01.tex) |
| 附录 B | 第二次作业全部 11 题 | 合订本 | [LaTeX](notes/exercises/homework02.tex) |

合订本包含五章、两组习题解答及各章复习题，沿用原有的 185 × 260 mm 版面、蓝灰定理框和可检索公式。分章版适合按进度阅读，合订本便于查找和打印。

本次整理覆盖已有学习讨论和课件译解，不以“笔记已整理”代替“已独立掌握”。第一次作业第 1–6 题尚未补录。第五章完整收至置信集合；此前讨论的 UMP 复习范围为原 Slides 第 1–27 页，UMPU 自第 28 页起。

## 来源

依据 Fang Yao 的 *Advanced Mathematical Statistics* 课程材料整理，加入中文说明、推导与习题解答。感谢原课程作者。本文是 [Studyer-Tang](https://github.com/Studyer-Tang) 的个人学习记录，非官方讲义或官方译本；原课件和作业不在本仓库重新发布。资料范围、编号约定和权利说明见 [SOURCES.md](SOURCES.md)。

## 构建

安装包含 XeLaTeX、`ctex`、Fandol 字体及本项目所用宏包的 TeX Live / TinyTeX。

```bash
# macOS / Linux
bash build.sh
```

```powershell
# Windows PowerShell
./build.ps1
```

脚本先在临时目录编译全部六份文档，检查输出非空，全部成功后再复制至 `output/pdf/`；编译失败时保留上一版。复制阶段并非文件系统事务，磁盘或权限错误后需修复环境并重新运行。Bash 优先使用 `latexmk`，其次 XeLaTeX，也可使用 Tectonic；PowerShell 使用 XeLaTeX。直接用 XeLaTeX 时脚本运行三遍，以稳定目录和交叉引用。

`main.tex` 仍为第一章入口，`chapter02.tex` 至 `chapter05.tex` 为其他分章入口，`complete.tex` 为合订本。正文只有一份，封面与版式分别共用 `frontmatter.tex`、`preamble.tex`，避免分章版与合订本内容分叉。

GitHub Actions 验证六个入口，并在 Linux、macOS、Windows 上检查构建脚本的成功、末份编译失败、缺失输出三类行为。运行脚本回归检查：

```bash
python -m unittest discover -s tests -v
```

## 修订

发现问题时，请给出章节、公式或题号、所需条件与反例。修订应同时更新正文、PDF 和 [勘误表](ERRATA.md)，避免只在讨论中改正。

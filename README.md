# Advanced Mathematical Statistics Notes

高等统计学中文学习笔记，按课程进度持续更新。内容依据 Fang Yao 老师的课程讲义整理，并加入术语翻译、直观解释、推导和学习中遇到的重点问题。

> 本项目是个人学习记录，并非课程官方讲义或官方译本。感谢 Fang Yao 老师提供原始讲义与课程框架。

## 作者

GitHub: [Studyer-Tang](https://github.com/Studyer-Tang)

## 当前进度

| 章节 | 内容 | 状态 |
| --- | --- | --- |
| 第 1 章 | 从样本到经验分布 | 已整理 |
| 1.1 | 概率论回顾 | 已整理 |
| 1.2 | 总体分布、样本与经验 CDF | 已整理 |
| 1.3 | 经验测度与代入原理 | 已整理 |
| 1.4 | 收敛方式与随机阶 | 已整理 |
| 1.5 | 极限定理与变换 | 已整理 |
| 后续章节 | 随课程推进更新 | 待学习 |

## 阅读

- [第 1 章 PDF](output/pdf/chapter-01-cn.pdf)
- [第 1 章 LaTeX 源文件](notes/chapter01/chapter01.tex)
- [学习进度记录](PROGRESS.md)

## 本地构建

需要安装包含 XeLaTeX 和 `ctex` 的 TeX Live。运行：

```powershell
./build.ps1
```

生成文件位于 `output/pdf/chapter-01-cn.pdf`。

## 项目结构

```text
.
├── main.tex                       # 文档入口与版式设置
├── notes/chapter01/chapter01.tex  # 第一章正文
├── output/pdf/                    # 发布版 PDF
├── PROGRESS.md                    # 学习进度和后续计划
└── build.ps1                      # Windows 构建脚本
```

## 更新方式

每学完一个知识块，就在对应章节源文件中补充翻译、理解、例题和疑问，同时更新 `PROGRESS.md`。推送后，GitHub Actions 会自动验证 PDF 能否正常编译，并提供构建产物。


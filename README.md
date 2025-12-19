# Bio-analysis-env
生信分析环境搭建指南
# 🧬 生信分析全能环境搭建指南 (Bioinformatics Analysis Environment)

![Conda](https://img.shields.io/badge/Conda-Forge-green) ![Bioconda](https://img.shields.io/badge/Bioconda-enabled-orange) ![Python](https://img.shields.io/badge/Python-3.10-blue) ![R](https://img.shields.io/badge/R-4.3.3-blue) ![License](https://img.shields.io/badge/license-MIT-grey)

本项目旨在提供一套**稳健、可复现、低冲突**的单细胞生信分析环境搭建方案。



**核心亮点：**
* ✅ **双语支持**：完美融合 Python (Scanpy) 与 R (Seurat V5) 流程。
* ✅ **底层优化**：通过 Conda 解决 R 包底层的 C/C++ 编译依赖（避免 `install.packages` 报错）。
* ✅ **Jupyter 集成**：一站式配置 Python 和 R 的 Jupyter Kernel。
* ✅ **难点攻克**：包含 CellChat 本地编译的详细解决方案（解决 LTO 链接错误）。

---

## 📋 目录 (Table of Contents)

* [1. 基础环境构建](#1-基础环境构建)
* [2. 核心软件安装](#2-核心软件安装-最关键步骤)
* [3. Jupyter Notebook 配置](#3-jupyter-notebook-配置-kernel-注册)
* [4. 扩展包安装](#4-安装常用生信扩展包)
* [5. 难点攻克：CellChat 安装](#5-难点攻克cellchat-安装)
* [6. 验证与使用](#6-验证环境)

---

## 1. 基础环境构建

### 1.1 创建并激活 Conda 环境
指定 Python 版本为 3.10，确保兼容性。

```bash
# 创建环境 (bio_env)
conda create -n bio_env python=3.10 -y

# 激活环境
conda activate bio_env

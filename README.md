这是一份为您整理好的、格式规范的 GitHub 项目 `README.md` 文档。

我对部分代码块进行了语法修正（特别是 Rprofile 部分的 URL 格式），并保留了折叠标签 (`<details>`) 以保持文档整洁。您可以直接复制以下内容到您的仓库中。

---

# 🧬 生信分析全能环境搭建指南 (Bioinformatics Analysis Environment)

本项目旨在提供一套**稳健、可复现、低冲突**的单细胞生信分析环境搭建方案。

**核心亮点：**

* ✅ **双语支持**：完美融合 Python (Scanpy) 与 R (Seurat V5) 流程。
* ✅ **底层优化**：通过 Conda 解决 R 包底层的 C/C++ 编译依赖（避免 `install.packages` 报错）。
* ✅ **Jupyter 集成**：一站式配置 Python 和 R 的 Jupyter Kernel。
* ✅ **难点攻克**：包含 CellChat 本地编译的详细解决方案（解决 LTO 链接错误）。

---

## 📋 目录 (Table of Contents)

* [1. 基础环境构建](<a id="## 1. 基础环境构建"></a>)
* [2. 核心软件安装]( )
* [3. Jupyter Notebook 配置]( )
* [4. 扩展包安装]( )
* [5. 难点攻克：CellChat 安装]( )
* [6. 验证与使用]( )

---

## 1. 基础环境构建

### 1.1 创建并激活 Conda 环境

指定 Python 版本为 3.10，确保兼容性。

```bash
# 创建环境 (bio_env)
conda create -n bio_env python=3.10 -y

# 激活环境
conda activate bio_env

```

### 1.2 配置镜像源

为了加速下载并确保依赖解析正确，必须添加 `conda-forge` 和 `bioconda` 频道，并设置优先级。

```bash
conda config --env --add channels conda-forge
conda config --env --add channels bioconda
conda config --env --set channel_priority strict

```

---

## 2. 核心软件安装 (最关键步骤)

> **⚠️ 重点策略**：严禁在 R 内部使用 `install.packages("Seurat")` 安装核心包，这会导致大量系统库编译错误。我们直接使用 Conda 预编译包。

```bash
# 同时安装 R 4.3, Seurat, Scanpy 及常用工具
# 注意：下载量较大，请保持网络通畅
conda install -n bio_env -c conda-forge -c bioconda \
  r-base=4.3.3 \
  r-seurat=4.3.0 \
  scanpy \
  python-igraph leidenalg \
  r-tidyverse r-devtools \
  -y

```

### 2.1 配置 R CRAN 镜像

配置清华镜像源以加速后续 R 包安装。

```bash
cat > ~/.Rprofile <<EOF
options(repos = c(CRAN = "https://mirrors.tuna.tsinghua.edu.cn/CRAN/"))
options(BioC_mirror = "https://mirrors.tuna.tsinghua.edu.cn/bioconductor")
EOF

```

---

## 3. Jupyter Notebook 配置 (Kernel 注册)

### 3.1 配置 Python Kernel (用于 Scanpy)

```bash
conda install ipykernel -y
# 注册名为 "Python (Bio-Scanpy)"
python -m ipykernel install --user --name=bio_env_py --display-name "Python (Bio-Scanpy)"

```

### 3.2 配置 R Kernel (用于 Seurat)

```bash
conda install r-irkernel -y
# 注册名为 "R (Bio-Seurat)"
R -e "IRkernel::installspec(name = 'bio_env_r', displayname = 'R (Bio-Seurat)')"

```

---

## 4. 安装常用生信扩展包

分批安装以避免 Conda 求解器超时。

### 4.1 可视化与差异分析

包含 `pheatmap`, `EnhancedVolcano`, `patchwork` 等。

<details>
<summary>🔻 点击展开安装命令</summary>

```bash
conda install -n bio_env -c conda-forge -c bioconda \
  r-clustree r-cowplot r-gtable r-gridextra \
  r-patchwork r-pheatmap r-msigdbr \
  bioconductor-enhancedvolcano r-matrix -y

```

</details>

### 4.2 富集分析 (ClusterProfiler)

包含 `clusterProfiler`, `fgsea`, `org.mm.eg.db` 等。

<details>
<summary>🔻 点击展开安装命令</summary>

```bash
conda install -n bio_env -c conda-forge -c bioconda \
  bioconductor-clusterprofiler bioconductor-fgsea \
  bioconductor-enrichplot bioconductor-org.mm.eg.db \
  bioconductor-dose r-ggalluvial r-hmisc -y

```

</details>

### 4.3 高级分析 (Monocle/SCENIC 依赖)与编译工具

安装 `cmake`, `gxx`, `monocle`, `AUCell` 等底层工具。

<details>
<summary>🔻 点击展开安装命令</summary>

```bash
# 依赖组 A
conda install -n bio_env -c conda-forge -c bioconda \
  bioconductor-monocle bioconductor-aucell bioconductor-rcistarget \
  bioconductor-complexheatmap r-nmnf cmake gxx_linux-64 -y

# 依赖组 B
conda install -n bio_env -c conda-forge -c bioconda \
  r-svglite r-ggpubr bioconductor-biocneighbors \
  r-nloptr r-lme4 r-car -y
  
# SCENIC 前置
conda install -n bio_env -c bioconda -c conda-forge \
  bioconductor-genie3 bioconductor-gsva -y  

```

</details>

### 4.4 系统底层编译环境

防止源码安装时出现 `gcc` 或 `make` 缺失报错。

```bash
conda install -n bio_env -c conda-forge \
  gxx_linux-64 gcc_linux-64 gfortran_linux-64 \
  make cmake binutils kernel-headers_linux-64 -y

```

---

## 5. 难点攻克：CellChat 安装

CellChat 包含大量 C++ 代码，直接安装极易报错。请严格按照以下步骤操作。

### 5.1 禁用 LTO (Link Time Optimization)

防止编译器优化导致的连接错误。

```bash
mkdir -p ~/.R
cat > ~/.R/Makevars <<EOF
CXX17FLAGS += -fno-lto
CXX14FLAGS += -fno-lto
CXX11FLAGS += -fno-lto
CFLAGS += -fno-lto
LDFLAGS += -fno-lto
EOF

```

### 5.2 准备与清理

假设 `CellChat-main.zip` 已上传至服务器。

```bash
# 解压
unzip -o CellChat-main.zip
# 【关键】清理旧的编译残留
rm -f CellChat-main/src/*.o
rm -f CellChat-main/src/*.so

```

### 5.3 R 内编译安装

在终端输入 `R` 进入交互模式：

```r
# 安装 NMF 依赖
if (!requireNamespace("NMF", quietly = TRUE)) install.packages("NMF")

# 指定路径安装 (请修改 path 为实际路径)
install.packages("/path/to/CellChat-main", 
                 repos = NULL, 
                 type = "source", 
                 lib = .libPaths()[2]) # 优先安装到 Conda 环境目录

```

---

## 6. 验证环境

### Python (Scanpy)

```python
import scanpy as sc
print(f"Scanpy version: {sc.__version__}")

```

### R (Seurat)

```r
library(Seurat)
library(tidyverse)
sessionInfo()

```

## 7. 日常使用

每次开始工作前：

```bash
conda activate bio_env
# 启动 Jupyter Lab
jupyter lab
# 或者直接使用 R/Python 命令行

```

---

### 下一步建议

为了让该项目更完善，您是否需要我为您生成配套的 **`environment.yml`** 配置文件？这可以让用户通过一条命令 `conda env create -f environment.yml` 自动完成前 4 步的所有安装。

#!/bin/bash

# 确保脚本出错即停止
set -e

echo ">>> 正在检查 Conda 环境..."
if [[ "$CONDA_DEFAULT_ENV" != "bio_env" ]]; then
    echo "错误: 请先激活环境! 运行: conda activate bio_env"
    exit 1
fi

echo ">>> 1. 配置 Jupyter Kernels..."
# 注册 Python Kernel
python -m ipykernel install --user --name=bio_env_py --display-name "Python (Bio-Scanpy)"
# 注册 R Kernel
R -e "IRkernel::installspec(name = 'bio_env_r', displayname = 'R (Bio-Seurat)')"

echo ">>> 2. 配置 R 镜像源 (清华源)..."
cat > ~/.Rprofile <<EOF
options(repos = c(CRAN = "https://mirrors.tuna.tsinghua.edu.cn/CRAN/"))
options(BioC_mirror = "https://mirrors.tuna.tsinghua.edu.cn/bioconductor")
EOF

echo ">>> 3. 配置编译参数 (禁用 LTO，为 CellChat 做准备)..."
mkdir -p ~/.R
cat > ~/.R/Makevars <<EOF
CXX17FLAGS += -fno-lto
CXX14FLAGS += -fno-lto
CXX11FLAGS += -fno-lto
CFLAGS += -fno-lto
LDFLAGS += -fno-lto
EOF

echo ">>> ✅ 配置完成！"
echo ">>> 您现在可以打开 Jupyter Lab 使用环境，或继续手动安装 CellChat。"

FROM pytorch/pytorch:2.14.1-cuda12.6-cudnn9-devel

# 让训练日志及时输出，并避免生成 Python 缓存文件
ENV PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1 \
    PIP_DISABLE_PIP_VERSION_CHECK=1 \
    LANG=C.UTF-8 \
    LC_ALL=C.UTF-8

# SSH、文件传输及常用诊断工具
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        ca-certificates \
        openssh-client \
        openssh-server \
        curl \
        git \
        nano \
        psmisc \
        zip \
        unzip && \
    mkdir -p /run/sshd && \
    rm -rf /var/lib/apt/lists/*

# Fair-IB-MVL 的依赖；范围与项目 pyproject.toml 保持一致
# 基础镜像已经包含 PyTorch，不再重复安装
RUN python -m pip install --upgrade pip setuptools wheel && \
    python -m pip install --no-cache-dir \
        "numpy>=1.26,<3" \
        "scipy>=1.14,<2" \
        "PyYAML>=6.0,<7" \
        "pytest>=8,<9"

# 构建阶段只检查软件版本，不要求构建机器有 GPU
RUN python -c "import sys, torch, numpy, scipy, yaml; \
assert (3, 10) <= sys.version_info[:2] < (3, 14), sys.version; \
assert torch.__version__.startswith('2.14.1'), torch.__version__; \
assert torch.version.cuda == '12.6', torch.version.cuda; \
print('Python:', sys.version); \
print('PyTorch:', torch.__version__); \
print('CUDA build:', torch.version.cuda); \
print('NumPy:', numpy.__version__); \
print('SciPy:', scipy.__version__); \
print('PyYAML:', yaml.__version__)"

WORKDIR /workspace

CMD ["/bin/bash"]

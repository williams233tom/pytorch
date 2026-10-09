FROM pytorch/pytorch:2.14.1-cuda12.6-cudnn9-runtime

ENV PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1 \
    PIP_DISABLE_PIP_VERSION_CHECK=1 \
    LANG=C.UTF-8 \
    LC_ALL=C.UTF-8

# 保留 SSH、虚拟环境及少量连接/诊断工具
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        ca-certificates \
        openssh-server \
        python3-venv \
        curl \
        psmisc && \
    mkdir -p /run/sshd && \
    rm -rf /var/lib/apt/lists/*

# 复用基础镜像中的 PyTorch，避免修改受保护的系统 Python
RUN python -m venv --system-site-packages /opt/fair_ib_env

ENV VIRTUAL_ENV=/opt/fair_ib_env
ENV PATH="/opt/fair_ib_env/bin:${PATH}"

# 仅安装训练和数据读写需要的依赖
RUN python -m pip install --no-cache-dir \
        "numpy>=1.26,<3" \
        "scipy>=1.14,<2" \
        "PyYAML>=6.0,<7"

# 构建时检查软件；不要求构建机器有 GPU
RUN python -c "import sys, torch, numpy, scipy, yaml; \
assert (3, 10) <= sys.version_info[:2] < (3, 14), sys.version; \
assert torch.__version__.startswith('2.14.1'), torch.__version__; \
assert torch.version.cuda == '12.6', torch.version.cuda; \
print('Training environment imports OK')"

WORKDIR /workspace

CMD ["/bin/bash"]

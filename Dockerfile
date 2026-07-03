FROM python:3.12

ARG TTK_REF=dev
ARG DEBIAN_FRONTEND=noninteractive


RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    ca-certificates \
    curl \
    xz-utils \
    build-essential \
    cmake \
    ninja-build \
    pkg-config \
    libboost-dev \
    libboost-system-dev \
    libboost-filesystem-dev \
    libboost-thread-dev \
    libeigen3-dev \
    libsqlite3-dev \
    libtbb-dev \
    libzstd-dev \
    zlib1g-dev \
    libqhull-dev \
    libgraphviz-dev \
    patchelf \
    && rm -rf /var/lib/apt/lists/*

ARG SDK_URL=https://vtk.org/files/wheel-sdks/vtk-wheel-sdk-9.5.2-cp312-cp312-manylinux2014_x86_64.manylinux_2_17_x86_64.tar.xz
ENV VTK_SDK_DIR=/opt/vtk-wheel-sdk
ENV VTK_DIR=/opt/vtk-wheel-sdk/vtk-9.5.2.data/headers/cmake
ENV CMAKE_PREFIX_PATH=/opt/vtk-wheel-sdk/vtk-9.5.2.data/headers/cmake

RUN mkdir -p "${VTK_SDK_DIR}" \
 && curl -L "${SDK_URL}" -o /tmp/vtk-wheel-sdk.tar.xz \
 && tar -xJf /tmp/vtk-wheel-sdk.tar.xz -C "${VTK_SDK_DIR}" --strip-components=1 \
 && rm /tmp/vtk-wheel-sdk.tar.xz

WORKDIR /src

RUN git clone --depth 1 --branch ${TTK_REF} https://github.com/topology-tool-kit/ttk.git

COPY pyproject.toml /src/ttk/pyproject.toml

WORKDIR /src/ttk

RUN python -m pip install -U pip build wheel scikit-build-core ninja cmake

RUN python -m build -w

RUN python -m zipfile -l /src/ttk/dist/*.whl | grep "topologytoolkit" | head -50 || true

RUN python -m pip install auditwheel

RUN mkdir -p /tmp/wheel /src/ttk/wheelhouse \
 && python -m zipfile -e /src/ttk/dist/*.whl /tmp/wheel \
 && LD_LIBRARY_PATH=/tmp/wheel/lib:$LD_LIBRARY_PATH \
    auditwheel repair \
      --exclude "libvtk*.so*" \
      --exclude "libvtk*.so.*" \
      /src/ttk/dist/*.whl \
      -w /src/ttk/wheelhouse

CMD ["/bin/bash"]

package: llamacpp
version: "%(tag_basename)s"
tag: b11160
license: MIT
source: https://github.com/ggml-org/llama.cpp
requires:
  - gpu-system
build_requires:
  - CMake
  - alibuild-recipe-tools
---
#!/bin/bash -e

# HIP when gpu-system found ROCm, CPU otherwise.
LLAMA_GPU_ARGS=()
if [[ ${O2_GPU_ROCM_AVAILABLE:-0} == 1 ]]; then
  # gfx906 (MI50) rocBLAS kernels are all but gone from ROCm >= 6.4: build against
  # 6.3 or the link succeeds and the first GEMM does not.
  ARCHS=${LLAMACPP_AMDGPU_TARGETS:-${O2_GPU_ROCM_AVAILABLE_ARCH:-$GPU_HIP_ARCHITECTURE}}
  LLAMA_GPU_ARGS=(-DGGML_HIP=ON
                  -DGPU_TARGETS="$ARCHS"
                  -DAMDGPU_TARGETS="$ARCHS"   # legacy spelling; forwarded pre-b11xxx
                  -DCMAKE_C_COMPILER="$O2_GPU_ROCM_HOME/llvm/bin/clang"
                  -DCMAKE_CXX_COMPILER="$O2_GPU_ROCM_HOME/llvm/bin/clang++")
fi

cmake "$SOURCEDIR"                                     \
  -DCMAKE_BUILD_TYPE=Release                           \
  -DCMAKE_INSTALL_PREFIX="$INSTALLROOT"                \
  -DLLAMA_CURL=OFF                                     \
  -DLLAMA_BUILD_TESTS=OFF                              \
  -DBUILD_SHARED_LIBS=ON                               \
  "${LLAMA_GPU_ARGS[@]}"                               \
  ${CMAKE_GENERATOR:+-G "$CMAKE_GENERATOR"}

cmake --build . ${JOBS:+-j $JOBS} --target install

mkdir -p "$INSTALLROOT/etc/modulefiles"
alibuild-generate-module --lib > "$INSTALLROOT/etc/modulefiles/$PKGNAME"

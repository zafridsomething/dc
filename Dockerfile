# Use an official NVIDIA CUDA image as a parent image
FROM nvidia/cuda:12.1.1-devel-ubuntu22.04

# Set environment variables
ENV DEBIAN_FRONTEND=noninteractive
ENV LLAMA_SERVER_PORT=8080
ENV MODEL_NAME=Llama-3.2-8X3B-MOE-Dark-Champion-Instruct-uncensored-abliterated-18.4B-GGUF-Q8_0.gguf
ENV MODEL_URL=https://huggingface.co/DavidAU/Llama-3.2-8X3B-MOE-Dark-Champion-Instruct-uncensored-abliterated-18.4B-GGUF/resolve/main/Llama-3.2-8X3B-MOE-Dark-Champion-Instruct-uncensored-abliterated-18.4B-GGUF-Q8_0.gguf

# Install dependencies
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    build-essential \
    git \
    wget && \
    rm -rf /var/lib/apt/lists/*

# Clone and compile llama.cpp
RUN git clone https://github.com/ggerganov/llama.cpp.git /opt/llama.cpp
WORKDIR /opt/llama.cpp
RUN make -j$(nproc) server LLAMA_CUDA=1

# Download the model
RUN mkdir -p /models && \
    wget -O /models/${MODEL_NAME} ${MODEL_URL}

# Expose port and set the command to run the server
EXPOSE ${LLAMA_SERVER_PORT}
CMD ["/opt/llama.cpp/server", \
     "-m", "/models/${MODEL_NAME}", \
     "-c", "131072", \
     "--port", "${LLAMA_SERVER_PORT}", \
     "--host", "0.0.0.0", \
     "-ngl", "999", \
     "--n-experts-used", "4"]
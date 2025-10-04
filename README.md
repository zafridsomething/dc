# Custom Docker Image for Llama 3.2 on OVH AI Deploy

This repository contains the necessary files to build a custom Docker image for deploying the [DavidAU/Llama-3.2-8X3B-MOE-Dark-Champion-Instruct-uncensored-abliterated-18.4B-GGUF](https://huggingface.co/DavidAU/Llama-3.2-8X3B-MOE-Dark-Champion-Instruct-uncensored-abliterated-18.4B-GGUF) model on [OVH AI Deploy](https://www.ovhcloud.com/en/public-cloud/ai-deploy/).

The image is built using `llama.cpp` with full NVIDIA CUDA acceleration, making it optimized for GPU instances like the L40S.

## Files

-   **`Dockerfile`**: This is the blueprint for our custom image. It handles all the necessary steps:
    -   Starts from an official NVIDIA CUDA base image.
    -   Installs all required system dependencies (`build-essential`, `git`, `wget`).
    -   Clones the `llama.cpp` repository from GitHub.
    -   Compiles the `llama.cpp` server with CUDA support (`LLAMA_CUDA=1`) to leverage the GPU.
    -   Downloads the high-quality `Q8_0` version of the model.
    -   Configures the server to start automatically with parameters optimized for your use case (128k context, 4 experts, all layers offloaded to GPU).

-   **`.dockerignore`**: This file ensures that local files like `.git` are not included in the Docker build context, which keeps the build process clean and efficient.

## Prerequisites

-   [Docker](https://www.docker.com/get-started) installed on your local machine.
-   An OVH Cloud account with access to AI Deploy and a private container registry.

## Step-by-Step Guide: Building and Deploying Your Model

Follow these instructions from your local terminal to build the image and push it to your private registry.

### Step 1: Log in to Your OVH Container Registry

First, you need to authenticate Docker with your private OVH container registry.

-   Find your registry address in the OVH Control Panel under `Public Cloud` > `Containers & Orchestration` > `Container Registry`. It will look something like `de.gcr.io` or `gra.gcr.io`.

Run the following command, replacing `<your-registry-address>` with your actual registry address. You will be prompted for your username and password.

```bash
docker login <your-registry-address>
```

### Step 2: Build the Docker Image

Now, navigate to the directory containing the `Dockerfile` and run the build command. You can name your image whatever you like.

-   Replace `<your-image-name>` with a descriptive name (e.g., `dark-champion-gguf`).
-   **Note:** The `.` at the end of the command is crucial—it tells Docker to use the current directory as the build context.

```bash
docker build -t <your-image-name> .
```

This process will take some time, as it needs to download the base image, compile `llama.cpp`, and download the ~20GB model file.

### Step 3: Tag the Image for Your Registry

Before you can push the image, you must tag it with the full path to your registry, including your namespace.

-   Find your namespace in the OVH Control Panel where you found your registry address.

```bash
docker tag <your-image-name> <your-registry-address>/<your-namespace>/<your-image-name>:latest
```

**Example:**
If your registry is `de.gcr.io`, your namespace is `my-models`, and you named your image `dark-champion-gguf`, the command would be:
`docker tag dark-champion-gguf de.gcr.io/my-models/dark-champion-gguf:latest`

### Step 4: Push the Image to Your Registry

Finally, push the tagged image to your private OVH registry.

```bash
docker push <your-registry-address>/<your-namespace>/<your-image-name>:latest
```

**Example:**
`docker push de.gcr.io/my-models/dark-champion-gguf:latest`

### Step 5: Deploy on OVH AI Deploy

With your image successfully pushed, you can now launch your model:

1.  Navigate to **AI Deploy** in your OVH Control Panel.
2.  Start a new AI app.
3.  When prompted to choose a Docker image, select **"Custom Image"**.
4.  In the "Docker image path" field, paste the full path of the image you just pushed (e.g., `de.gcr.io/my-models/dark-champion-gguf:latest`).
5.  The `Dockerfile` exposes port `8080`, which OVH should detect automatically.
6.  Select a GPU instance (e.g., L40S) for deployment.
7.  Launch the app.

Once the app is running, you can access the `llama.cpp` server's API at the URL provided by AI Deploy.

### Interacting with the API

You can interact with the model using any OpenAI-compatible client library or by making direct API calls. Here is an example using `curl`:

```bash
curl --request POST \
  --url http://<your-app-url>.ai-apps.io/v1/chat/completions \
  --header "Content-Type: application/json" \
  --data '{
    "model": "Llama-3.2-8X3B-MOE-Dark-Champion-Instruct-uncensored-abliterated-18.4B-GGUF-Q8_0.gguf",
    "messages": [
      {
        "role": "system",
        "content": "You are a helpful assistant."
      },
      {
        "role": "user",
        "content": "Tell me a joke."
      }
    ]
  }'
```

Enjoy your custom model deployment!
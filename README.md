# tensorflow-cpu-docker
A Docker/Dev Container setup to run Tensorflow using the CPU in VSCode

The process for getting this running was rather painful due to the ins and outs of Dockerfiles, etc., so I thought I would share and perhaps save someone the effort.
This is set up to run Tensorflow without using CUDA/GPU, it uses the CPU instead.

There are a couple of things to change:
- `USERNAME`, `TF_VERSION`, `PYTHON_VERSION` at the top of `Dockerfile`.
- Your username in `remoteUser` in devcontainer.json.
From there, you should be able to use the Dev Containers extension in VSCode to Rebuild and Reopen in Container, then run the tensorflow_mnist_test.py file to see if everything works.

# Change these as needed
ARG USERNAME=john
ARG TF_VERSION=2.15.0.post1
ARG PYTHON_VERSION=3.11


# Use the existing image as the base
FROM tensorflow/tensorflow:${TF_VERSION}

ARG USERNAME
ARG TF_VERSION
ARG PYTHON_VERSION

ENV USERNAME=${USERNAME}
ENV TF_VERSION=${TF_VERSION}
ENV PYTHON_VERSION=${PYTHON_VERSION}

# Set the working directory
WORKDIR /workspace

# Create a user and group with specified IDs
RUN groupadd -g 1000 ${USERNAME} && \
    useradd -u 1000 -g 1000 -m -s /bin/bash ${USERNAME}

USER root

# Set timezone to EST and configure tzdata non-interactively
ENV TZ=America/New_York
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update && \
    apt-get install -y tzdata && \
    ln -fs /usr/share/zoneinfo/America/New_York /etc/localtime && \
    dpkg-reconfigure --frontend noninteractive tzdata

# Install the desired Python version
RUN apt-get update --fix-missing \
    && apt-get install -y software-properties-common git wget gnupg \
    && wget -qO - 'https://keyserver.ubuntu.com/pks/lookup?op=get&search=0x6A755776' | apt-key add - \
    && echo "deb http://ppa.launchpad.net/deadsnakes/ppa/ubuntu jammy main" > /etc/apt/sources.list.d/deadsnakes-ppa.list \
    && apt-get update \
    && rm -rf /var/lib/apt/lists/* \
    && apt install -y python${PYTHON_VERSION} python${PYTHON_VERSION}-dev python${PYTHON_VERSION}-venv python${PYTHON_VERSION}-distutils \
    && update-alternatives --install /usr/bin/python3 python3 /usr/bin/python${PYTHON_VERSION} 1 \
    && update-alternatives --install /usr/bin/python python /usr/bin/python${PYTHON_VERSION} 1 \
    && rm -rf /var/lib/apt/lists/* \
    && apt clean

USER ${USERNAME}

# Install additional Python packages
RUN pip install --no-cache-dir \
    lxml==5.2.1 \
    mne==1.7.0 \
    edfio==0.4.0 \
    numpy==1.26.4 \
    scikit-learn==1.4.2 \
    scipy==1.13.0 \
    ipykernel==6.29.4 \
    tensorflow-datasets \
    dvc


USER root
# Install VSCode packages (extensions)
RUN apt-get update && apt-get install -y wget \
    && wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > microsoft.gpg \
    && install -o root -g root -m 644 microsoft.gpg /etc/apt/trusted.gpg.d/ \
    && sh -c 'echo "deb [arch=amd64] https://packages.microsoft.com/repos/vscode stable main" > /etc/apt/sources.list.d/vscode.list' \
    && apt-get update \
    && apt-get install -y code

# Other packages
RUN apt-get install -y sudo

RUN usermod -aG sudo ${USERNAME}
RUN echo "${USERNAME} ALL=(ALL) NOPASSWD:ALL" >>/etc/sudoers

USER ${USERNAME}

RUN sh -c 'echo "export PATH=$PATH:/home/${USERNAME}/.local/bin" >>~/.bashrc'

USER root
RUN rm -rf /var/lib/apt/lists/* microsoft.gpg

RUN apt-get clean

# Switch to the new user
USER ${USERNAME}

# Set the entrypoint (optional)
CMD ["bash"]



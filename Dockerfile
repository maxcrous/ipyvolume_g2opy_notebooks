# This dockerfile creates an image that allows one to 
# run jupyter notebook binders with g2opy and ipyvolume support. 
FROM python:3.9

# install the notebook package
RUN pip install --no-cache --upgrade pip && \
    pip install --no-cache notebook jupyterlab && \
    pip install --no-cache numpy matplotlib ipyvolume==0.6.0a7 opencv-python 

# Install system dependencies
RUN mkdir -p /var/lib/apt/lists
RUN set -ex && apt-get update && apt-get install --no-install-recommends -y \
        libeigen3-dev \
	git \
	cmake \
	libsuitesparse-dev \
	qtdeclarative5-dev \
	qt5-qmake \
	npm

# Install extension required for running ipyvolume in jupyter lab
RUN python -m jupyter labextension install bqplot jupyter-threejs jupyterlab-datawidgets ipyvolume

# Install g2o python bindings
RUN git clone https://github.com/LukasBommes/g2opy && mkdir g2opy/build
WORKDIR g2opy/build 
RUN cmake .. && make -j8 
WORKDIR ..
RUN python setup.py install 

# Remove apt repository information
RUN rm -rf /var/lib/apt/lists/*

# For Binder, create user with a home directory, taken from Binder tutorial
ARG NB_USER=jovyan
ARG NB_UID=1000
ENV USER ${NB_USER}
ENV HOME /home/${NB_USER}

RUN adduser --disabled-password \
    --gecos "Default user" \
    --uid ${NB_UID} \
    ${NB_USER}
WORKDIR ${HOME}
USER ${USER}
RUN pwd

# Clone the git repository with notebooks
RUN git clone https://github.com/maxcrous/multiview_notebooks.git
WORKDIR ./multiview_notebooks


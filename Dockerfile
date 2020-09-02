
# start from base with centos & qt5
FROM slicer/buildenv-qt5-centos7:latest

WORKDIR /usr/src

# get basics for the gui
RUN yum install Xvfb Xorg mesa-dri-drivers libGLEW gcc -y

# get slicer nighly version
RUN git clone -b master https://github.com/Slicer/Slicer.git

# create slicer-build and environment
RUN mkdir /usr/src/Slicer-build && \
    cd /usr/src/Slicer-build && \ 
    # build slicer
    cmake \
    -DCMAKE_BUILD_TYPE:STRING=Release \
    -DQt5_DIR:PATH=${Qt5_DIR} \
    -DSlicer_USE_SimpleITK:BOOL=OFF \
    -DSlicer_USE_QtTesting:BOOL=OFF \
    /usr/src/Slicer && \
    # build dependencies
    make -j 32

# create environment variables
ENV PATH="${PATH}:/usr/src/Slicer-build/python-install/bin"
ENV PYTHONPATH="${PYTHONPATH}:/usr/src/Slicer-build/python-install/bin/PythonSlicer"
ENV SLICER=/usr/src/Slicer

# Create ExtensionsIndex
#RUN git clone git://github.com/Slicer/ExtensionsIndex.git && \
#    mkdir ExtensionsIndex-build && cd ExtensionsIndex-build && \
#    cmake -DSlicer_DIR:PATH=/usr/src/Slicer-build/Slicer-build -DSlicer_EXTENSION_DESCRIPTION_DIR:PATH=../ExtensionsIndex \
#    -DCMAKE_BUILD_TYPE:STRING=Release ${SLICER}/Extensions/CMake && \
#    make -j 32

# Install Elastix
RUN PythonSlicer -c "import sys;print(sys.path)"
RUN PythonSlicer -m pip install --upgrade pip
RUN PythonSlicer -m pip install pytest-cov

# start running container
CMD bash

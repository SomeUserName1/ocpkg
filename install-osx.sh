#!/bin/bash

build_repo()
{
	cd $1
	mkdir build
	cd build
	cmake ..
	make && sudo make install
	cd ../..
}

report()
{
	printf "\n\n$log\n\n"
}

# Install the homebrew package

log="----------Installing/Updating Homebrew----------"; report
if [ "$(which brew)" = "brew not found" ]
then /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
else
brew update
fi

# Install all the dependencies

log="----------Installing dependencies----------"; report
brew install gcc cmake boost gsl guile docker docker-compose docker-machine xhyve docker-machine-driver-xhyve

log="----------Setting up docker----------"; report
sudo chown root:wheel $(brew --prefix)/opt/docker-machine-driver-xhyve/bin/docker-machine-driver-xhyve
sudo chmod u+s $(brew --prefix)/opt/docker-machine-driver-xhyve/bin/docker-machine-driver-xhyve
docker-machine create default --driver xhyve --xhyve-experimental-nfs-share
eval $(docker-machine env default)


# Editing the bash_profile

echo 'alias g++="g++-5 --std=c++1y -fext-numeric-literals"' >> ~/.bash_profile
echo 'alias gcc="/usr/local/Cellar/gcc/5.1.0/bin/gcc-5"' >> ~/.bash_profile
echo 'export CC="/usr/local/Cellar/gcc/5.1.0/bin/gcc-5"'
echo 'export CXX="g++-5 --std=c++1y -fext-numeric-literals"'
source ~/.bash_profile

# Fetch OpenCog source repositories

log="----------Fetching repositories from git----------"; report
log="-------------------------OC-----------------------"; report
mkdir OC && cd OC
git clone git@github.com:opencog/cogutil
git clone git@github.com:opencog/atomspace
git clone git@github.com:opencog/moses
git clone git@github.com:opencog/opencog
git clone git@github.com:opencog/semantic-vision.git
git clone git@github.com:opencog/link-grammar.git
git clone git@github.com:opencog/loving-ai.git
git clone git@github.com:opencog/external-tools.git
git clone git@github.com:opencog/docker.git


# Set environment path variables

export DYLD_LIBRARY_PATH="/usr/local/lib/opencog/modules:/usr/local/lib/opencog/"
export PYTHONPATH="/usr/local/share/opencog/python:/opencog/opencog/python/:/opencog/build/opencog/cython:/opencog/opencog/nlp/anaphora:$PYTHONPATH"
cp /usr/local/lib/opencog/* /usr/local/lib/

# Define TCP_IDLETIME, edit IRC.cc
file="./opencog/opencog/nlp/irc/IRC.cc"
sed -i '1i\
#define TCP_KEEPIDLE 14400\
' $file

# Edit PyMindAgent.cc to make OS X compatible
file="./opencog/opencog/cogserver/modules/python/PyMindAgent.cc"
sed -i '1i\
#include <Python.h>\
' $file
sed -i '0,/if __GNUC__/s/if __GNUC__/if __GNUC__ \&\& INIT_PRIORITY \&\& ((GCC_VERSION >= 40300) || (CLANG_VERSION >= 20900))/' $file

./../OC/build_osx.sh

#!/bin/bash

build_repo()
{
	cd $1
	mkdir build
	cd build
	cmake ..
	make -j 8 && sudo make install
	cd ../..
}

report()
{
	printf "\n\n$log\n\n"
}


log="----------Building Cogutil----------"; report
build_repo cogutil
log="----------Building atomspace----------"; report
build_repo atomspace
log="----------Building MOSES----------"; report
build_repo moses
log="----------Building OpenCog----------"; report
build_repo opencog
log="----------Building semantic vision----------"; report
build_repo semantic-vision
log="----------Building link-grammar----------"; report
build_repo link-grammar
log="----------Building loving-ai----------"; report
build_repo loving-ai
log="----------Building Ext-tools----------"; report
build_repo external-tools
log="----------Successfully Built----------"; report

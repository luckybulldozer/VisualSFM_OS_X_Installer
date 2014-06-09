#!/bin/bash
# Visual SFM installer for OS X
#
# Copyright Dan Monaghan 2014 www.luckybulldozer.com
#
# Please check out our short film Sifted at http://www.vimeo.com/69136384
# 
# Should be as simple as it gets!
#
# To run, cd into the directory of the installer and simply execute this script via…
#    sh vsfm_os_x_installer_mavericks.sh
#
#
#
# This program is free software: you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation, either version 3 of the License, or
#    (at your option) any later version.
#
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#
#    You should have received a copy of the GNU General Public License
#    along with this program.  If not, see <http://www.gnu.org/licenses/>.
#
#
# Credits go to Changchang Wu for VisualSFM
# Structure from Motion
# [1] Changchang Wu, "Towards Linear-time Incremental Structure From
# Motion", 3DV 2013
# [2] Changchang Wu, "VisualSFM: A Visual Structure from Motion System",
# http://ccwu.me/vsfm/, 2011
#
# + Bundle Adjustment
# [3] Changchang Wu, Sameer Agarwal, Brian Curless, and Steven M. Seitz,
# "Multicore Bundle Adjustment", CVPR 2011
#
#
#  Feature Detection
# [4] Changchang Wu, "SiftGPU: A GPU implementation of Scale Invaraint
# Feature Transform (SIFT)", http://cs.unc.edu/~ccwu/siftgpu, 2007
#
#
# PMVS2  Yasutaka Furukawa http://www.cs.washington.edu/homes/furukawa/
#
# [Initial Cmake multiplatform port ]	Pierre moulon pmoulon[AT]gmail.com
# [CMVS/PMVS] http://http://grail.cs.washington.edu/software/cmvs/
# [CMake version] http://opensourcephotogrammetry.blogspot.com/
# https://github.com/TheFrenchLeaf/CMVS-PMVS
#
# Graclus -- Efficient graph clustering software for normalized cut and ratio association on undirected graphs.
#
# Copyright(c) 2008 Brian Kulis, Yuqiang Guan (version 1.2)
#
# http://www.cs.utexas.edu/users/dml/Software/graclus.html/
#
# Homebrew
#
# http://mxcl.github.com/homebrew/
#
#
# Big thanks for Iván Rodríguez Murillo's original OS X installer
# https://github.com/iromu





#### Let the script begin.


# check if script has been run as root, it should be.
if [[ $EUID -eq 0 ]]; then
echo "This script should not need to be run as root.  Exiting"
exit 1
fi

# function Declarations defined below...

function lineBreak (){
echo ""
}

function echoGood () {
INPUT_TEXT=$1
printf "\e[0;32m${INPUT_TEXT}\e[0m\n"
}

function echoBad () {
INPUT_TEXT=$1
printf "\e[0;31m${INPUT_TEXT}\e[0m\n"
}

function checkBrew() {
if which $1 >/dev/null;
	then 
		echo "$1 is already installed, OK"
	else
		echo "$1 is not installed... brewing now."
		brew install $1
	fi
}

function installBrews () {
		brew install jpeg
		brew install gdk-pixbuf --cc=llvm-gcc
		brew install cairo
	    	brew install freetype
		brew link freetype
		brew install pango
		brew link pixman
		brew link fontconfig
		brew install gtk+
		brew install glew
		brew install gsl
		brew install boost
		brew install intltool
		brew install cmake
		brew tap homebrew/versions
		brew install gcc48
		brew install devil
#maybe....
#		brew install mesalib-glw

}


############## int main.... lol


echo ""
echoGood "Dan Monaghan's VSFM and PMVS installer of OS X"
echo ""

echo "About to check to see if you have the Brew Package Manager"
if which brew >/dev/null; 
	then
	     echoGood "Sweet, you've got brew... Continuing"
	else
	     echoGood "Nope, Ok I will install... you'll have to enter your root password at somestage to complete." 
		ruby -e "$(curl -fsSL https://raw.github.com/Homebrew/homebrew/go/install)"
fi


checkBrew wget
#checkBrew function defined at bottom


# check to see if we have the right XQuartz....

echo "Checking we have the right version of XQuartz"
echo ""
cat /Applications/Utilities/XQuartz.app/Contents/Info.plist | awk '/<key>CFBundleShortVersionString<\/key>/{getline; print}' | grep 2.7.6 && echo "Good" || echo "Not good..."
echo ""
if [ $? -ne 0 ]
then 
	echoBad "We must download the right version of XQuartz... one moment while we install"
	wget http://xquartz.macosforge.org/downloads/SL/XQuartz-2.7.6.dmg 
	open XQuartz-2.7.6.dmg
	echo "Switch to finder and install XQuartz as per the installer. Then log in and out and then run script 2"
else
	echoGood "Your version of XQuartz is 2.7.6 - perfect."
fi

lineBreak; echo "Ok, now you have to should have either...";lineBreak
echo "1. Already had the correct version of XQuartz, so I'm continuing...";lineBreak
echo "2. Had to have installed XQuartz and just logged out and back in...";lineBreak
echo "Ready to continue the next installation of VSFM & PMVS   (press ENTER)";lineBreak

echo "Installing Brew packages... this can take quite a long time"

# installBrews
installBrews
# installing VSFM Section

function installVSFM () {

    VSFM_ZIP=VisualSFM_osx_64bit.zip
	VSFM_SRC=http://ccwu.me/vsfm/download/VisualSFM_osx_64bit.zip

if [[ ! -f $VSFM_ZIP ]]; then
		echoBadd "VSFM Zip not present, downloading..."    
		wget $VSFM_SRC -O VisualSFM_osx_64bit.zip
		unzip $VSFM_ZIP
	else
		echoGood "Zip file is present, so just unzipping, removing old dir to install so we don't have any conflicts"
		rm -fR vsfm
		unzip $VSFM_ZIP
fi

cd vsfm

	echo "Changing VSFM GCC to Brews gcc-4.8"
	S=$(echo CC = g++ -w | sed -e 's/\//\\\//g')
	R=$(echo CC = g++-4.8 -w | sed -e 's/\//\\\//g')
	sed -i '' -e "s/${S}/${R}/" makefile
	
	echo "Changing /usr/x11/lib to OS X default /opt/x11/lib"
	S=$(echo -L/usr/x11/lib | sed -e 's/\//\\\//g')
	R=$(echo -L/opt/X11/lib | sed -e 's/\//\\\//g')
	sed -i '' -e "s/${S}/${R}/" makefile
	
	echoGood "About to make..."
	make -f makefile	
if [[ $? -eq 0 ]]; then
		echoGood "VSFM application built... moving on"
	else
		echoBad "VSFM application failed to build, halting."
	exit
fi

cd ..

}

installVSFM

##### SIFT GPU PHASE

function installSiftGPU () {

	SIFT_GPU_SRC=http://wwwx.cs.unc.edu/~ccwu/cgi-bin/siftgpu.cgi
	SIFT_GPU_ZIP=sift_gpu.zip

if [[ ! -f $SIFT_GPU_ZIP ]]; then
    echoBad "SiftGPU Zip not present, downloading..."    
	wget $SIFT_GPU_SRC -O $SIFT_GPU_ZIP 
	unzip $SIFT_GPU_ZIP    
	else
	echo "LIB_SIFT_GPU is present, skipping download and unzip. removing old dir to install so we don't have any conflicts"
                 rm -fR SiftGPU
	unzip $SIFT_GPU_ZIP
fi

cd SiftGPU
	echo "Changing SiftGPU GCC to Brews gcc-4.8"
	S=$(echo CC = g++ | sed -e 's/\//\\\//g')
	R=$(echo CC = g++-4.8 -w | sed -e 's/\//\\\//g')
	sed -i '' -e "s/${S}/${R}/" makefile
	
	echo "Disable Cuda Flags"
	S=$(echo siftgpu_enable_cuda = 1 | sed -e 's/\//\\\//g')
	R=$(echo siftgpu_enable_cuda = 0 's/\//\\\//g')
	sed -i '' -e "s/${S}/${R}/" makefile
	
	echo "Changing march from native core2 in makefile"
	S=$(echo native | sed -e 's/\//\\\//g')
	R=$(echo core2 | sed -e 's/\//\\\//g')
	sed -i '' -e "s/${S}/${R}/" makefile	

	echo "Changing to prefer GLUT"
	S=$(echo siftgpu_prefer_glut = 0 | sed -e 's/\//\\\//g')
	R=$(echo siftgpu_prefer_glut = 1 | sed -e 's/\//\\\//g')
	sed -i '' -e "s/${S}/${R}/" makefile		

	echo "Removing -L/opt/local/lib from makefile"
	S=$(echo -L/opt/local/lib | sed -e 's/\//\\\//g')
	R=$(echo | sed -e 's/\//\\\//g')
	sed -i '' -e "s/${S}/${R}/" makefile
	
	echo "Changing /usr/x11/lib to OS X default /opt/x11/lib"
	S=$(echo -L/usr/x11/lib | sed -e 's/\//\\\//g')
	R=$(echo -L/opt/X11/lib | sed -e 's/\//\\\//g')
	sed -i '' -e "s/${S}/${R}/" makefile

make siftgpu
	if [[ $? -eq 0 ]]; then
			echoGood "libsiftgpu.so built... moving on"
		else
			echoBad "libsiftgpu.so failed to build.  Halting."
		
		exit
	fi

cd ..

}

installSiftGPU

function installPBA () {

	LIB_PBA_SRC=http://grail.cs.washington.edu/projects/mcba/pba_v1.0.5.zip
	LIB_PBA_ZIP=pba_v1.0.5.zip

if [[ ! -f $LIB_PBA_ZIP ]]; then
    echo "VSFM Zip not present, downloading..."    
	wget $LIB_PBA_SRC -O $LIB_PBA_ZIP 
	unzip $LIB_PBA_ZIP    
	else
	echo "LIB_PBA is present, skipping download and unzip, removing old dir to install so we don't have any conflicts"
                 rm -fR pba
	unzip $LIB_PBA_ZIP 
fi

cd pba

	echo "Changing SiftGPU GCC to Brews gcc-4.8"
	S=$(echo CC = g++ | sed -e 's/\//\\\//g')
	R=$(echo CC = g++-4.8 -w | sed -e 's/\//\\\//g')
	sed -i '' -e "s/${S}/${R}/" makefile_no_gpu

	echo "Removing /usr/lib64 from makefile"
	S=$(echo /usr/lib64 | sed -e 's/\//\\\//g')
	R=$(echo | sed -e 's/\//\\\//g')
	sed -i '' -e "s/${S}/${R}/" makefile_no_gpu	
	
	
	echo "Changing march from native core2 in makefile"
	S=$(echo native | sed -e 's/\//\\\//g')
	R=$(echo core2 | sed -e 's/\//\\\//g')
	sed -i '' -e "s/${S}/${R}/" makefile_no_gpu	

	echo "Adding -L/usr/include/sys/ to compile Flags"
	S=$(echo -L/usr/lib | sed -e 's/\//\\\//g')
	R=$(echo -L/usr/lib -L/usr/include/sys/ | sed -e 's/\//\\\//g')
	sed -i '' -e "s/${S}/${R}/" makefile_no_gpu	

cp ../patches/SparseBundleCPU.patch src/pba/
cd src/pba
patch < SparseBundleCPU.patch
cd ../..
echoGood $PWD
make -f makefile_no_gpu pba
	if [[ $? -eq 0 ]]; then
			echoGood "libpba.so built... moving on"
		else
			echoBad "libpba.so failed to build, halting."		
		exit
	fi

cd ..

}

installPBA

function installPMVS () {
#set flags for cmake to honor
#export CXX=/usr/local/opt/gcc48/bin/g++-4.8
#export CC=/usr/local/opt/gcc48/bin/gcc-4.8

PMVS_ZIP=PMVS_pmoulonGit.zip
PMVS_SRC=https://github.com/pmoulon/CMVS-PMVS/archive/master.zip

if [[ ! -f $PMVS_ZIP ]]; then
		echoBad "PMVS Zip not present, downloading..."    
		wget $PMVS_SRC -O $PMVS_ZIP
		unzip $PMVS_ZIP
	else
		echoGood "Zip file is present, so just unzipping, removing old dir to install so we dont have any conflicts"
                rm -fR CMVS-PMVS-master
		unzip $PMVS_ZIP
fi

cd CMVS-PMVS-master/program

	echo "Adding set CMAKE_EXE_LINKER_FLAGS -static-libgcc -static-libstdc++ to cmake flags"
	cat ../../patches/cflag_var > temp
	cat CMakeLists.txt >> temp
	mv CMakeLists.txt OLD_CMakeLists
	mv temp CMakeLists.txt
	mkdir build
	cd build
	echoGood $PWD
	cmake . ..
	make	
	if [[ $? -eq 0 ]]; then
			echoGood "CMVS & PMVS built... moving on"
		else
			echoBad "libpba.so failed to build, halting...."		
		exit
	fi

cd ../../..
echoGood $PWD

}

installPMVS

function makeVSFMdir () {

cp pba/bin/libpba_no_gpu.so vsfm/bin/libpba.so
cp SiftGPU/bin/libsiftgpu.so vsfm/bin/
cp CMVS-PMVS-master/program/build/main/pmvs2 vsfm/bin
cp CMVS-PMVS-master/program/build/main/genOption vsfm/bin
cp CMVS-PMVS-master/program/build/main/cmvs vsfm/bin
} 

makeVSFMdir
if [[ $? -eq 0 ]]; then
			echoGood "Success!  Opening VSFM dir"
			echoGood "To run from command line make sure the directory you finally locate VSFM is in your PATH"
			open vsfm/bin/
		else
			echoBad "Failure.  End of script"		
		exit
	fi
### END OF SCRIPT

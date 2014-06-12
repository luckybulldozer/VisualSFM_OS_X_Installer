VisualSFM_OS_X_Mavericks_Installer
==================================

VisualSFM installer script for OS X Mavericks


Here's a quick guide on how to use the installer.

1. Get the installer from the github page where it says "Download ZIP"... since you are here=]

2. Go to your Downloads folder and you should see a directory called "VisualSFM_OS_X_Mavericks_Installer-master"

3. In Terminal, cd into that directory...  e.g.:  

$ cd ~/Downloads/VisualSFM_OS_X_Mavericks_Installer-master/

4. Execute the script ( no need to sudo )

$ sh vsfm_os_x_installer_mavericks.sh

5.  The script goes on to check that you have brew installed, and the Xcode command line tools (which requires an admin password to install).  The script also checks for the precise version of XQuartz 2.7.6 at that point (I'm sure we can relax on that later in the installer).  If you have the wrong version of XQuartz, 2.7.6 is downloaded and you are prompted to install it.  You then have to log in and out again to make sure you can continue.

6.  We then install all the rest to the necessary brews, and maybe even a few we don't need!  GCC4.8 seems to take a long time on an old dual core laptop, so please be patient.

7. VisualSFM is downloaded, patched and made, this gets the VSFM GUI working.

8. libsiftgpu.so is downloaded, patched and made, this gets the sift working working (currently under CUDA if CUDA is installed - need more checks here I suspect).

9. libpba_no_gpu.so is made, sorry, no gpu at this stage.

10. PMVS-CMVS from the pmoulon github is built, seems to compile under clang pretty well.

11.  All files are copied into the vsfm/bin directory that is ready to work with, just double click on VisualSFM, add it to your dock perhaps (only works in the far right hand part of the dock).

12... stay tuned for updates, but that's pretty much the procedure in a nutshell.

Cheers,
Dan Monaghan
www.luckybulldozer.com

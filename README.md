# Siril_WSL
A set of Bash scripts to automate processing of astrophotography images using Siril program, under Windows. It's best to be used with WSL, but can also be used with Cygwin.

In particular, these scripts can help you to manage your growing collection of astrophotography images, and do a single or multi-nights image processing, for broadband and narrowband OSC images.

The scripts are developed for a specific setup, but can be adopted to other setups.

This is the default setup:
 - OSC cameras with either UV/IR or dual narrow band filters.
 - All the images are organized by the "Camera + filter" combination (I call it simply "Camera"). E.g. SV705C (with UV/IR filter), and SV705Cn (with the narrow band filter).
 - The images are orqanized in folders with the following structure: CAMERA / DATE / TARGET
 - Inside each "CAMERA / DATE / TARGET" folder, there is LIGHT folder containing the light images (fits files, cr2 files etc). There is also "FlastWizard / Flat" folder containing the flats from that night.
 - I am not using Darks (my cameras don't need them). You should provide one master Bias file inside each CAMERA folder. It should have a name starting with master_bias_***.
 - The above folders structure is produced automatically inside NINA image aquisition software. I create a separate NINA profile for each CAMERA (that is, for each camera + filter combination; I have two cameras and 2 filters, so I have 4 profiles).
 - Here is an example of one such NINA image naming scheme (using SV705C camera as an example): SV705C\$$DATEMINUS12$$\$$TARGETNAME$$\$$IMAGETYPE$$\$$DATETIME$$_$$EXPOSURETIME$$s_$$FRAMENR$$ . This profile will lautomatically create all the required folders, including the "FlastWizard / Flat" folder when using the Flat wizard to create flats.

The scripts will process "FlastWizard / Flat" images into a pp_flat_stacked.fits file for the given session the first time you run the script. Next time, it will detect the stacked file, and will skip the flats stacking step.

The current scripts are:
- list_objects.sh : lists all the imaging sessions, organized by target and camera. It provides the total exposure (also the number of shots, and individual shot exposure) for each night for each target, and also the cumulative exposure across multiple nights for the same target/camera.
- siril_1night.sh : processing one session for a specific camera, target , and date - for broadband imaging.
- narrow_1night.sh : same, but for dual narrow band imaging. It uses the operations from the HaOIII Siril script. Produces both Ha and OIII with binning=2x2 (can be changed).
- siril_multy_nights.sh : processing broadband imaging from multiple nights for the same camera and target. With an optional -n argument, will process together both broad and narrowband images from multiple nights.
- config.h : contains a few global settings for the scripts.

Installation (assuming WSL)

Open the WSL terminal. Install the package using the git clone command, say in the home directory. Update the PATH variable inside the ~/.bashrc file to point to the installation directory, e.g. (replace USER with your user name):

export PATH=/home/USER/Siril_WSL:$PATH
cd

The scripts can be accessed from Windows (explorer etc) using this path (again, replace USER with your user name):

\\wsl.localhost\Ubuntu\home\USER\Siril_WSL

Modify config.h file: update the ROOT_DIR location (this is the path to the root of your images folder; ideally it should be on a fast SSD disk). If you have some folder names inside ROOT_DIR which show up incorrectly as a camera name or a target name, add those exceptions to the EXCLUDE variable definition.

You can also install this under Cygwin, but in my experience WSL works much faster, especially the list_objects.sh command which does a lot of file reading.

Limitations:
 - Camera names (which are NINA profile names) should not contain spaces. So use Canon6D, not Canon 6D, for the profiles.
 - Folder names (cameras, targets, LIGHT, process etc) and file names (image names etc) are case sensitive. So e.g. image.fits is different from image.FITS.

Here is a typical output from list_objects.sh command:


 *** All cameras ***
Canon6D
SV705C
SV705Cn

 *** All targets ***
3I_Atlas
M101
M82
NGC 6543
NGC 6946
NGC 7331
Pillars

 ======= 3I_Atlas =======
   * Camera: Canon6D *
Canon6D/2025-07-03/"3I_Atlas" : 96 shots 60.0s each; 1.6 hours
Cumulative exposure = 1.6 hours

   * Camera: SV705C *
SV705C/2025-07-14/"3I_Atlas" : 147 shots 30.00s each; 1.225 hours
SV705C/2025-07-18/"3I_Atlas" : 189 shots 30.00s each; 1.575 hours
SV705C/2025-07-20/"3I_Atlas" : 106 shots 30.00s each; 0.883333 hours
SV705C/2025-07-22/"3I_Atlas" : 150 shots 30.00s each; 1.25 hours
Cumulative exposure = 4.93333 hours


 ======= M101 =======
   * Camera: Canon6D *
Canon6D/2025-06-29/"M101" : 73 shots 120.0s each; 2.43333 hours
Cumulative exposure = 2.43333 hours


 ======= M82 =======
   * Camera: Canon6D *
Canon6D/2025-05-19/"M82" : 21 shots 60.0s each; 0.35 hours
Cumulative exposure = 0.35 hours


 ======= NGC 6543 =======
   * Camera: SV705Cn *
SV705Cn/2025-07-23/"NGC 6543" : 1 shots 300.00s each; 0.0833333 hours
Cumulative exposure = 0.0833333 hours


 ======= NGC 6946 =======
   * Camera: Canon6D *
Canon6D/2025-07-01/"NGC 6946" : 219 shots 120.0s each; 7.3 hours
Canon6D/2025-07-03/"NGC 6946" : 28 shots 120.0s each; 0.933333 hours
Cumulative exposure = 8.23333 hours

   * Camera: SV705C *
SV705C/2025-07-18/"NGC 6946" : 309 shots 30.00s each; 2.575 hours
SV705C/2025-07-27/"NGC 6946" : 95 shots 120.00s each; 3.16667 hours
Cumulative exposure = 5.74167 hours

   * Camera: SV705Cn *
SV705Cn/2025-07-23/"NGC 6946" : 32 shots 300.00s each; 2.66667 hours
SV705Cn/2025-08-01/"NGC 6946" : 61 shots 300.00s each; 5.08333 hours
Cumulative exposure = 7.75 hours


 ======= NGC 7331 =======
   * Camera: SV705C *
SV705C/2025-07-20/"NGC 7331" : 284 shots 30.00s each; 2.36667 hours
SV705C/2025-07-22/"NGC 7331" : 114 shots 120.00s each; 3.8 hours
SV705C/2025-07-27/"NGC 7331" : 90 shots 120.00s each; 3 hours
Cumulative exposure = 9.16667 hours


 ======= Pillars =======
   * Camera: SV705Cn *
SV705Cn/2025-07-23/"Pillars" : 29 shots 300.00s each; 2.41667 hours
Cumulative exposure = 2.41667 hours

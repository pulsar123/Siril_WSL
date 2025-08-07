# Global parameters for Siril_bash

# Root directory for the fits files
ROOT_DIR=/mnt/i/NINA

version=$(siril.exe --version |awk '{print $2}')
ext=fits

# Additional arguments to pass to register command:
REGISTER_ARGS="-minpairs=5"


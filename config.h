# Global parameters for Siril_bash

# Root directory for the fits files
ROOT_DIR=/mnt/i/NINA

version=$(siril.exe --version |awk '{print $2}')
ext=fits

# Additional arguments to pass to register command:
REGISTER_ARGS="-minpairs=5"

# Directory names which should be excluded (they are neither camera nor target names):
# The names can contain spaces. The case is not important.
EXCLUDE="(snapshot|cache|process|flatwizard|templates|targets|logs|bias)"

source /cad/modules/tcl/init/sh

module load base/1.0
module load genesis2
module load xcelium/19.03.003
module load icadv/12.30.712 
module load incisive/15.20.022
module load vcs/O-2018.09-SP1
module load genus/19.10.000 
module load innovus/19.10.000
module load lc/M-2017.06-SP3 
module load syn/P-2019.03

########################################################################
# Loading calibre/2019.1 results in loading mentor versions of binaries
# e.g.
#   /cad/mentor/2019.1/aoi_cal_2019.1_18.11/bin/tclsh and python3
#
# These binaries *do not work* on ubuntu systems. Worse, they usurp
# the previously existing/working binaries in your path so that if
# you try to run e.g. "python3" or "tclsh" from the command line you
# just get the cryptic error "Invalid operating system environment".
#
# Because tclsh is thusly poisoned, the "module load" commands stop
# working, among whatever other bad things might happen.
#
# My fix is to just skip this load if the OS is Ubuntu...

tmp=`lsb_release -i | awk '{print $NF}'`
if [ "$tmp" == "Ubuntu" ]; then
    echo "Skipping calibre load because its binaries don't work under Ubuntu"
else
    module load calibre/2019.1
fi

module load pts/M-2017.06
module load ext/latest



# Add python version 3 to your environment
#scl enable rh-python34 "tcsh"

# Setup GENESIS2 by including the GEN2 executable in your path
#setenv GENESIS_HOME "/usr/local/GENESIS2/genesis2-master"
#set path=($GENESIS_HOME/bin $GENESIS_HOME/gui/bin $path)
#setenv PERL5LIB "$GENESIS_HOME/PerlLibs/ExtrasForOldPerlDistributions"
#setenv PERL5LIB "$GENESIS_HOME/gui/configs/install/perlfiles:$PERL5LIB"


# Setup vcs by including the VCS executable in your path
setenv PATH /usr/local/synopsys/vcs_2022.06/bin:$PATH
setenv PATH /usr/local/synopsys/verdi_2022.06/verdi/T-2022.06-SP2-1/bin:$PATH

# This is an env argument for some scripts
setenv SIM_ENGINE synopsys

# VCS_HOME is used by some of the scripts
setenv VCS_HOME /usr/local/synopsys/vcs_2022.06/ 
setenv VERDI_HOME /usr/local/synopsys/verdi_2022.06/verdi/T-2022.06-SP2-1/

# Setup Licenses
setenv SNPSLMD_LICENSE_FILE 27020@enlicense5.eas.asu.edu
setenv LM_LICENSE_FILE 27020@enlicense5.eas.asu.edu

setenv SYNOPSYS /usr/local/synopsys/starrc_2015.06/linux64/syn/



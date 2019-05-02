#!/bin/sh

#BSUB -J gdas_gempak_00
#BSUB -o /gpfs/dell2/ptmp/Boi.Vuong/output/gdas_gempak_00.o%J
#BSUB -e /gpfs/dell2/ptmp/Boi.Vuong/output/gdas_gempak_00.o%J
#BSUB -q debug
#BSUB -n 2                      # number of tasks
#BSUB -R span[ptile=1]          # 1 task per node
#BSUB -cwd /gpfs/dell2/ptmp/Boi.Vuong/output
#BSUB -W 00:30
#BSUB -P GFS-T2O
#BSUB -R affinity[core(1):distribute=balance]

export KMP_AFFINITY=disabled

export PDY=`date -u +%Y%m%d`
export PDY=20181207

export PDY1=`expr $PDY - 1`

export cyc=00
# export cyc=12
export cycle=t${cyc}z

set -xa
export PS4='$SECONDS + '
date

####################################
##  Load the GRIB Utilities module
#####################################
module load EnvVars/1.0.2
module load ips/18.0.1.163
module load CFP/2.0.1
module load impi/18.0.1
module load lsf/10.1
module load grib_util/1.1.0
###########################################
# Now set up GEMPAK/NTRANS environment
###########################################
module use -a /gpfs/dell1/nco/ops/nwpara/modulefiles/
module load gempak/7.3.1
module list

############################################
# GDAS GEMPAK PRODUCT GENERATION
############################################
# set envir=prod or para to test with data in prod or para
 export envir=para
# export envir=prod

export SENDCOM=YES
export KEEPDATA=YES
export job=gdas_gempak_${cyc}
export pid=${pid:-$$}
export jobid=${job}.${pid}

# Set FAKE DBNET for testing
export SENDDBN=YES
export DBNROOT=/gpfs/hps/nco/ops/nwprod/prod_util.v1.0.24/fakedbn

export DATAROOT=/gpfs/dell2/ptmp/Boi.Vuong/output
export NWROOT=/gpfs/dell2/emc/modeling/noscrub/Boi.Vuong/git
export COMROOT2=/gpfs/dell2/ptmp/Boi.Vuong/com

mkdir -m 775 -p ${COMROOT2} ${COMROOT2}/logs ${COMROOT2}/logs/jlogfiles
export jlogfile=${COMROOT2}/logs/jlogfiles/jlogfile.${jobid}

#############################################################
# Specify versions
#############################################################
export gfs_ver=v15.0.0

##########################################################
# obtain unique process id (pid) and make temp directory
##########################################################
export DATA=${DATA:-${DATAROOT}/${jobid}}
mkdir -p $DATA
cd $DATA

################################
# Set up the HOME directory
################################
export HOMEgfs=${HOMEgfs:-${NWROOT}/gfs.${gfs_ver}}
export EXECgfs=${EXECgfs:-$HOMEgfs/exec}
export PARMgfs=${PARMgfs:-$HOMEgfs/parm}
export PARMwmo=${PARMwmo:-$HOMEgfs/parm/wmo}
export PARMproduct=${PARMproduct:-$HOMEgfs/parm/product}
export FIXgfs=${FIXgfs:-$HOMEgfs/gempak/fix}
export USHgfs=${USHgfs:-$HOMEgfs/gempak/ush}
export SRCgfs=${SRCgfs:-$HOMEgfs/scripts}

######################################
# Set up the GEMPAK directory
#######################################
export HOMEgempak=${HOMEgempak:-${NWROOTp1}/gempak}
export FIXgempak=${FIXgempak:-$HOMEgempak/fix}
export USHgempak=${USHgempak:-$HOMEgempak/ush}

###################################
# Specify NET and RUN Name and model
####################################
export NET=${NET:-gfs}
export RUN=${RUN:-gdas}
export model=${model:-gdas}

##############################################
# Define COM, COMOUTwmo, COMIN  directories
##############################################
if [ $envir = "prod" ] ; then
  export COMIN=/gpfs/hps/nco/ops/com/gfs/prod/${RUN}.${PDY}         ### NCO PROD
else
 export COMIN=/gpfs/dell1/nco/ops/com/gfs/para/${RUN}.${PDY}/${cyc} ### NCO PARA Realtime
# export COMIN=/gpfs/dell3/ptmp/emc.glopara/ROTDIRS/prfv3rt1/${RUN}.${PDY}/${cyc} ### EMC PARA Realtime
# export COMIN=/gpfs/hps3/ptmp/emc.glopara/ROTDIRS/prfv3rt1/${RUN}.${PDY}/${cyc} ### EMC PARA Realtimea on CRAY
#  export COMIN=/gpfs/dell2/emc/modeling/noscrub/Boi.Vuong/git/${RUN}.${PDY}/${cyc} ### Boi PARA
fi

export COMOUT=${COMROOT2}/${NET}/${envir}/${RUN}.${PDY}/${cyc}/nawips

if [ $SENDCOM = YES ] ; then
  mkdir -m 775 -p $COMOUT
fi

#############################################
# run the GFS job
#############################################
sh $HOMEgfs/jobs/JGDAS_GEMPAK

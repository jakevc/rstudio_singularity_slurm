#!/bin/bash
##
## Run Rstudio server through SOCKS5 tunnel on a SLURM allocated node.
## Jake VanCampen, Kohl Kinning, November 2018
##
set -euo pipefail

usage ()
{
	 echo "Usage: $(basename $0) [-h] [-n node] [-u remote_user] [-r remote_host] [-p port]" >&2
	 exit 1
}

# exit if no arguments supplied
if [ $# -eq 0 ]
then
   usage
   exit 1
fi

# define default local variable  
NODE=n013
PORT=8123

# Process command line arguments
while getopts ":h:n::u::r::p:" opt; do
  case ${opt} in
    n ) NODE=$OPTARG ;;
    u ) USER=$OPTARG ;;
    r ) REMOTE=$OPTARG;; 
    p ) PORT=$OPTARG;;
    h ) usage;;
    ? ) usage;;
  esac
done
shift $((OPTIND -1))

echo "Writing server command." 
# get commands to run Rstudio server on talapas 
echo "#!/bin/bash
/usr/sbin/fuser -k 8787/tcp
module load singularity
singularity pull --name singularity-rstudio.simg shub://nickjer/singularity-rstudio
singularity run --app rserver ~/singularity-rstudio.simg" > rserver.sh

# make sure it's executable 
chmod 755 rserver.sh

echo "Copying runscript to HPC."
echo "rsync -av rserver.sh $USER@$REMOTE:~/"
rsync -av rserver.sh $USER@$REMOTE:~/

# remove rserver.sh from your machine
rm rserver.sh

echo "Starting Rstudio server on $NODE."
# Start the Rserver
ssh $USER@$REMOTE -o RemoteCommand="srun -w $NODE rserver.sh" & 


echo "Create SOCKS5 proxy tunnel from $NODE, through $REMOTE, to localhost:$PORT."
# forward the port using a proxy command
ssh -D $PORT -N -f -C -q -o ProxyCommand="ssh $USER@$REMOTE exec nc %h %p" $USER@$NODE

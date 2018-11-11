# rstudio_singularity_slurm
Run Rstudio server on remote host with SLURM using a SOCKS5 tunnel.

This is a repository for the script `rstudio_singularity.sh` which allows you to run Rstudio server on a remote server using the SLURM workload manager. This script assumes the availability of singularity on the remote machine, and loads it using the `module load singularity` command.

```
./rstudio_slurm.sh -h
Usage: rstudio_slurm.sh [-h] [-n node] [-u remote_user] [-r remote_host] [-p port]
```

# Setup

To run this script, first make sure you have passphrase-less SSH access to the remote server. This can be done with ssh-keygen to create an rsa key-pair, then copying the public key to the list of authorized keys on the server. For more information on SSH key-pair authentication see this [post](https://www.digitalocean.com/community/tutorials/how-to-configure-ssh-key-based-authentication-on-a-freebsd-server). 

# Accessing Rstudio server from Firefox

To Access Rstudio server through the SOCKS5 tunnel, download firefox if you do not alrady have it and edit the network settings.

In Firefox, go to Preferences > Advanced > Network and find the Connection settings.

	- Click "Manual Proxy Configuration" and type "localhost" in the SOCKS Host box. Type the port you intend to use when calling `./rstudio_slurm.sh` in the Port box. 
	- Check the box that says "Proxy DNS when using SOCKS v5". 

![](https://github.com/jakevc/rstudio_singularity_slurm/blob/master/firefox_setup.png | width=700, height=300) 

Once this is setup, run the server script like so:

```
./rstudio_slurm.sh -n n013 -u bob -r remote.server -p 8123
```

This will request n013 from SLURM and begin running Rstudio server in a singularity container on that node. Then a SOCKS tunnel will be established from n013 to your localhost:8123. If you setup your firefox correctly, when you navigate to n013:8787 in the firefox address bar, you will be redirected to the Rstudio instance running on n013. 

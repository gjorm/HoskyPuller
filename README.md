1) In your Home directory, create a folder called Dev, then <code>cd</code> into the Dev folder, create a folder called HoskyPuller and <code>cd</code> into the HoskyPuller folder.

2) Download HoskyPuller bash scripts into this folder with <code>wget https://github.com/gjorm/HoskyPuller/archive/refs/heads/main.zip</code>. Unzip with <code>unzip main.zip</code>
	>The zip file that github makes has all of the scripts the 'HoskyPuller-main' folder so the next step is to copy/cut and paste these back into Dev/HoskyPuller

3) Download both the cardano-wallet (https://github.com/input-output-hk/cardano-wallet/releases) and cardano-node (https://hydra.iohk.io/job/Cardano/cardano-node/cardano-node-linux/latest-finished) linux pre-built binary files and unzip.
	>Note 1: Don't download the source files, and don't install either of these with Docker.
	>Note 2: All of the cardano-node files will end up in the HoskyPuller folder and the cardano-wallet files will end up in a new folder inside of the HoskyPuller folder with a naming convention similar to 'cardano-wallet-*date*-linux64'
	
4) Rename the 'cardano-wallet-*date*-linux64' folder to 'cardano-wallet' for the wallet scripts to work.

5) Hosky Puller has a single dependancy: jq. Install jq with <code>sudo apt install jq -y</code> or with whatever package manager your distro uses

6) Run <code>./hp-start-cardano-node.sh</code>

7) Wait until cardano-node achieves sync with the blockchain (see next step for progress update). This will take at least several hours on the first start up.

8) Open a new terminal window or tab. Start the wallet server with <code>./hp-start-wallet-server.sh</code>
	>If the node isnt synced yet then the wallet server cant start, so the script will report the sync progress
	>When the wallet server is running, you must give it time to sync as well.
	
9) Open a new Terminal window or tab and run the Hosky Puller script with <code>./hp-start-pulling-hosky.sh</code>

10) The script will test if any wallets exist and if so, it will simply choose the first wallet in the list. If no wallet exists, it will restore a wallet from a recovery phrase that you provide via space a delimited string of words. The script does not perform any checks of any kind to ensure the spelling of the words, or if the words exist in the BIP39 scheme. It is entirely upon you to provide the correct recovery phrase. After this, the script will error out until the wallet is synced.
	>Watch the tab with the wallet server running to view sync progress.
	>Once it achieves sync, run <code>./hp-start-pulling-hosky.sh</code>. Now Hosky Puller will begin blowing your Ada on this worthless shitcoin.

11) Read and mind these important notes about the Hosky Puller scripts (these are not optional):
<ul>
	<li>a) Use Hosky Puller at your own risk! These are poorly written buggy garbage and could fail in an awful manner. By using these scripts you acknowledge that you take on all liability in the event that something goes wrong and you lose funds. If you dont want this liability, then do not use these scripts.</li>
	<li>b) Do NOT use your main wallet with the Hosky Puller scripts! The Hosky Puller script will draw down whatever Ada is in your wallet down to less than 1 Ada and it does not care what wallet you give it. It also does not check to see what Hosky has come back due to the doggy bowl being out of service with some frequency. The only thing stopping it is you manually having to enter your password.</li>
	<li>c) Before running the hp-start-pulling-hosky.sh script, create a new wallet in your wallet manager of choice and write down the recovery pass phrase. Send a small amount of Ada to it and then use it for the Hosky Puller script.</li>
	<li>d) Test the Hosky Puller script by replacing the address located in the hp-doggy-bowl-address text file with an address of your own separate wallet and run the script to test the functionality. If 2 Ada shows up in this other wallet that you own, then consider pulling the trigger and put the doggy bowl address back into the hp-doggy-bowl-address text file.</li>
	<li>e) Load your new Hosky pulling wallet with the amount of Ada you can afford to blow and run hp-start-pulling-hosky.sh at your own risk.</li>
</ul>


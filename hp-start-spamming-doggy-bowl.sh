#!/bin/bash

# *
# * hp-start-pulling-hosky.sh
# *
# * Copyright 2021 gjorm <https://github.com/gjorm>
# *
# * This program is free software; you can redistribute it and/or modify
# * it under the terms of the GNU General Public License as published by
# * the Free Software Foundation; either version 2 of the License, or
# * (at your option) any later version.
# *
# * This program is distributed in the hope that it will be useful,
# * but WITHOUT ANY WARRANTY; without even the implied warranty of
# * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# * GNU General Public License for more details.
# *
# * You should have received a copy of the GNU General Public License
# * along with this program; if not, write to the Free Software
# * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston,
# * MA 02110-1301, USA.
# *
# *
# *

#Get the date and time in ISO 8601 format, UTC time
function getTimeStamp {
	theDate=$(date -u -Iseconds)
        echo "${theDate%??????}"Z
}

#grab the newest transaction in the transaction list
function getNewestTransactionId {
	walletIdF=$1
	nowDate=$(getTimeStamp)
	
	trans=$(cardano-wallet/./cardano-wallet transaction list "$walletIdF" --start "$startDate" --end "$nowDate" --order descending)
	
	#the time stamp window is very small and could produce a null result
	if [ "$trans" = null ]; then
		exit 0
	fi

	#reassign trans to this latest outgoing transaction
	trans=$(echo "$trans" | jq '.[] | select(.direction == "outgoing")')
			
	stat=$(echo "$trans" | jq '.status' | tr -d '"') #grab the status field from the transaction data
	if [ "$stat" = "in_ledger" ]; then #make sure it is not a failed transaction
		#output the the tx id
		echo "$trans" | jq '.id' | tr -d '"'
	fi	
}

#make sure the wallet balance is > 3,000,000 lovelace
function ensureGoodBalance {
	walletIdF=$1
	bool=false
	balance=$(cardano-wallet/./cardano-wallet wallet get "$walletIdF" | jq '.balance|.total|.quantity' | tr -d '"')
	if [ "$balance" -gt 3000000 ]; then
		bool=true
	fi
	echo "$bool"
}

#return the balance in the wallet
function getBalance {
        walletIdF=$1
        balance=$(cardano-wallet/./cardano-wallet wallet get "$walletIdF" | jq '.balance|.total|.quantity' | tr -d '"')
        echo "$balance"
}

#send a 2000000 lovelace transaction to the doggy bowl
function sendTransaction {
	walletIdF=$1
	cardano-wallet/./cardano-wallet transaction create "$walletIdF" --payment 2000000@"$doggyBowlAddr" --metadata '{ "0":{ "string":"cardano" } }' > /dev/null
}

#grab the first wallet in the list of wallets
function grabFirstWallet {
	cardano-wallet/./cardano-wallet wallet list | jq '.[0]?|.id' | tr -d '"'
}

function testWalletSyncStatus {
	walletIdF=$1
	cardano-wallet/./cardano-wallet wallet get "$walletIdF" | jq '.state|.status' | tr -d '"'
}

############End of function definitions


doggyBowlAddr=$(cat hp-doggy-bowl-address)
startDate=$(getTimeStamp)
numPulls=0

#check to see if a wallet exists
walletId=$(grabFirstWallet)
if [ "$walletId" = null ]; then #if walletId is empty
	cardano-wallet/./cardano-wallet wallet create from-recovery-phrase "Husky Puller"
	walletId=$(grabFirstWallet)
fi
echo -e "Using wallet id: $walletId\n"

#test to make sure wallet is synced and exit if not
if [ "$(testWalletSyncStatus "$walletId")" != "ready" ]; then
	echo -e "Wallet not synced with wallet server.\n"
	exit 1
fi

#load and store password for usage with sending transactions
echo "Enter your wallets password for the Hosky Puller script to use when sending transactions."
read -s password

#print which address is being sent to
echo -e "Sending pulls to address: $doggyBowlAddr\n"
#print off inital balance
echo -e "Initial Wallet balance: $(getBalance "$walletId")\n"

#on the first round just fire off a transmission to the doggy bowl
sendTransaction "$walletId"
echo "Sending off first pull"

#grab the newest transaction, then loop until there is no more Ada
while [ "$(ensureGoodBalance "$walletId")" = true ]
do
	yes "$password" | sendTransaction "$walletId"
	numPulls=$((numPulls + 1))
	echo "Sending pull number $numPulls"
	echo -e "Wallet balance: $(getBalance "$walletId")\n"
	sleep 1
done


echo "Number of pulls from the doggy bowl: $numPulls"


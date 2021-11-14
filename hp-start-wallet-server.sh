#!/bin/bash

# *
# * hp-start-wallet-server.sh
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

export CARDANO_NODE_SOCKET_PATH=~/Dev/HoskyPuller/node.socket
gProgS=$(./cardano-cli query tip --mainnet | jq '.syncProgress' | tr -d '"')
#use bc to test the equality of the progress value
gProgI=$(bc <<< "$gProgS >= 100")
if [ "$gProgI" -eq 1 ]; then
	cardano-wallet/./cardano-wallet serve --mainnet --node-socket "$CARDANO_NODE_SOCKET_PATH" --database cardano-wallet --token-metadata-server https://tokens.cardano.org
else
	echo "Cardano Node not synced yet: $gProgS percent. "
fi

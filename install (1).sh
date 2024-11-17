#!/bin/bash

main() {
    clear
    echo -e "Welcome to the MacSploit Experience!"
    echo -e "Install Script Version 2.6"
    echo -e "No license required! Enjoy MacSploit for free!"

    # Download jq utility
    echo -n "Downloading jq utility... "
    curl -sSL "https://github.com/stedolan/jq/releases/download/jq-1.6/jq-osx-amd64" -o "./jq"
    if [ ! -f ./jq ]; then
        echo "Failed to download jq. Please check your internet connection."
        exit 1
    fi
    chmod +x ./jq
    echo "Done."

    # Download Roblox version info
    echo -e "Downloading Latest Roblox..."
    local robloxVersionInfo=$(curl -s "https://clientsettingscdn.roblox.com/v2/client-version/MacPlayer")
    if [ -z "$robloxVersionInfo" ]; then
        echo "Failed to fetch Roblox version info. Please check your connection."
        exit 1
    fi
    local robloxVersion=$(echo $robloxVersionInfo | ./jq -r ".clientVersionUpload")

    # Download RobloxPlayer.zip
    echo -e "Downloading RobloxPlayer.zip..."
    curl -sSL "http://setup.rbxcdn.com/mac/$robloxVersion-RobloxPlayer.zip" -o "./RobloxPlayer.zip"
    if [ ! -f ./RobloxPlayer.zip ]; then
        echo "Failed to download RobloxPlayer.zip. Please check your internet connection."
        exit 1
    fi

    # Install Roblox
    echo -n "Installing Latest Roblox... "
    [ -d "/Applications/Roblox.app" ] && rm -rf "/Applications/Roblox.app"
    unzip -o -q "./RobloxPlayer.zip" || {
        echo "Failed to unzip RobloxPlayer.zip. The file might be corrupted."
        exit 1
    }
    mv ./RobloxPlayer.app /Applications/Roblox.app
    rm ./RobloxPlayer.zip
    echo "Done."

    # Download and install MacSploit
    echo -e "Downloading MacSploit..."
    curl -sSL "https://git.raptor.fun/main/macsploit.zip" -o "./MacSploit.zip"
    if [ ! -f ./MacSploit.zip ]; then
        echo "Failed to download MacSploit.zip. Please check your connection."
        exit 1
    fi
    echo -n "Installing MacSploit... "
    unzip -o -q "./MacSploit.zip"
    mv ./MacSploit.app /Applications/MacSploit.app
    rm ./MacSploit.zip
    echo "Done."

    # Update and patch Roblox
    echo -n "Updating Dylib..."
    curl -sSL "https://git.raptor.fun/main/macsploit.dylib" -o "./macsploit.dylib"
    curl -sSL "https://git.raptor.fun/main/libdiscord-rpc.dylib" -o "./libdiscord-rpc.dylib"
    if [ -f ./macsploit.dylib ] && [ -f ./libdiscord-rpc.dylib ]; then
        mv ./macsploit.dylib "/Applications/Roblox.app/Contents/MacOS/macsploit.dylib"
        mv ./libdiscord-rpc.dylib "/Applications/Roblox.app/Contents/MacOS/libdiscord-rpc.dylib"
        ./insert_dylib "/Applications/Roblox.app/Contents/MacOS/macsploit.dylib" "/Applications/Roblox.app/Contents/MacOS/RobloxPlayer" --strip-codesig --all-yes
        mv "/Applications/Roblox.app/Contents/MacOS/RobloxPlayer_patched" "/Applications/Roblox.app/Contents/MacOS/RobloxPlayer"
        rm -r "/Applications/Roblox.app/Contents/MacOS/RobloxPlayerInstaller.app"
        rm ./insert_dylib
        echo "Done."
    else
        echo "Failed to download dylib files. Please check your connection."
        exit 1
    fi

    echo -e "Install Complete! Developed by Nexus42!"
    rm ./jq
    exit
}

main

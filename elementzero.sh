#!/bin/bash
/proc/self/exe --version 2>/dev/null | grep -q 'GNU bash' && USING_BASH=true || USING_BASH=false
if [ "$USING_BASH" != true ]; then
echo It looks like you are running this script with sh or some other shell.
echo Please run it again with bash.
exit 1
fi
echo "________________________________"
echo "| ========================= //  |"
echo "| ||                      //    |"
echo "| ||                    //      |"
echo "| ||  =========       //        |"
echo "| ||                //          |"
echo "| ||              //            |"
echo "| ||=========== // ==========   |"
echo "|_______________________________|"
echo
echo Automatic ElementZero Installer
read -p "Press enter to start..." goaway
echo =====================================
#Make sure sudo is installed
which sudo > /dev/null 2>&1
export sudocheckerrorlevel=$?
if [ "$sudocheckerrorlevel" != "0" ]; then
echo Sudo could not be found on your system. It is required for the install.
echo Please install sudo and add yourself to sudoers, then try again.
exit 1
fi
#Test root access
echo Enter root password
sudo sh -c "exit" > /dev/null 2>&1
export rootcheckerrorlevel=$?
if [ "$rootcheckerrorlevel" != "0" ]; then
echo Could not gain root access. Please make sure you are a sudoer and
echo that you entered the correct password, then try again.
exit 2
fi
echo =====================================
#Install docker if not installed. Also add user to docker group
which docker > /dev/null 2>&1
export dockercheckerrorlevel=$?
if [ "$dockercheckerrorlevel" != "0" ]; then
echo Docker not installed. installing...
wget https://get.docker.com -O /tmp/getdocker.sh
sh /tmp/getdocker.sh
sudo adduser docker
fi
#If its still not installed, quit
which docker > /dev/null 2>&1
export dockercheckerrorlevel=$?
if [ "$dockercheckerrorlevel" != "0" ]; then
echo Docker Install failed. Try restarting this script or installing manually.
exit 3
fi
read -p "Make sure this script is in the folder you want your server to be installed to and press enter." goaway
echo =====================================
#Download BDS
echo Now its time to sign your soul off to Microsoft.
echo Before I download BDS, Confirm that you agree to the
echo Minecraft EULA https://minecraft.net/terms and
echo Microsoft Privacy Policy https://go.microsoft.com/fwlink/?LinkId=521839
read -p "Press Enter to agree. Otherwise push CTRL+C" goaway
echo =====================================
#Use bash magic to get the url of the latest BDS release from minecraft.net then download it
echo Locating Latest BDS
export bdsurl=`wget http://www.minecraft.net/en-us/download/server/bedrock/ -q -O - | grep -o https://minecraft.azureedge.net/bin-win/bedrock-server.*zip`
echo Downloading BDS
rm /tmp/bds.zip > /dev/null
wget $bdsurl -q --show-progress -O /tmp/bds.zip
#Do the same thing for ElementZero
echo Locating Latest ElementZero
export ezurl=http://github.com`wget https://github.com/Element-0/ElementZero/releases/latest -q -O - | grep -o /Element-0/ElementZero/releases/download/.*/ElementZero-.*-win64.zip | head -n 1`
rm /tmp/ez.zip > /dev/null
echo Downloading ElementZero
wget $ezurl -q --show-progress -O /tmp/ez.zip
echo =====================================
#Extract both
echo Extracting files...
sudo unzip -q /tmp/bds.zip -d .
sudo unzip -q /tmp/ez.zip -d .
cd ElementZero*
sudo mv * ../
cd ../
rmdir ElementZero*
echo =====================================
echo Now we need to do some configuration...
echo "If you don't know what you're doing, just click enter and accept the default."
read -p "What Port do you want to use? (19132)> " port
if [ "$port" == "" ]; then
export port="19132";
fi
read -p "Enter a name for the docker container (MyServer)> " containername
if [ "containername" == "" ]; then
export port="MyServer";
fi
echo Creating start script
echo "docker run --name $containername -d --rm -ti -p $port:$port/udp -v $PWD:/data codehz/wine:bdlauncher-runtime" >> start.sh
echo "echo To open server shell, run the following command" >> start.sh
echo "echo sudo docker attach $containername" >> start.sh
echo =====================================
echo If all went well, you now have a minecraft server available in the
echo current directory!
echo 'To start it, run "sh start.sh"'
echo 'To attach, run "docker attach $containername"'
echo To detach, do CTRL+P and then CTRL+Q
echo 'And to stop, Attach and then run "stop" in the server console.'
exit 0

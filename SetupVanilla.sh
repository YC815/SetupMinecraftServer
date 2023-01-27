#!/bin/bash
# Original Minecraft Server Installation Script - James A. Chambers - https://www.jamesachambers.com.
# Changes and simplifications by Marc Tönsing

echo "Minecraft伺服器安裝腳本 by James Chambers, Marc Tönsing & 老明 - V1.91 繁中翻譯 & 修改: 犽YC815"
echo "最新版本在 https://github.com/YC815/SetupMinecraftServer"

# 讀取total記憶體
Get_ServerMemory(){
	TotalMemory=$(awk '/MemTotal/ { printf "%.0f\n", $2/1024 }' /proc/meminfo)
	AvailableMemory=$(awk '/MemAvailable/ { printf "%.0f\n", $2/1024 }' /proc/meminfo)
	echo "Total memory: $TotalMemory - Available Memory: $AvailableMemory"
	
	if [ $TotalMemory -lt 1001 ]; then
		echo "樹莓派記憶體為1GB，自動設定Minecraft最高記憶體為800MB"
		MemSelected=800
	elif [ $TotalMemory -lt 2001 ]; then
		echo "樹莓派記憶體為2GB，自動設置Minecraft最高記憶體為1800MB"
		MemSelected=1800
    elif [ $TotalMemory -lt 4001 ]; then
        echo "樹莓派記憶體為4GB，自動設置Minecraft最高記憶體為3800MB"
        MemSelected=3800
    elif [ $TotalMemory -lt 8001 ]; then
        echo "樹莓派記憶體為8GB，自動設置Minecraft最高記憶體為7800MB"
        MemSelected=7800 
	fi
}

# 腳本
Update_Scripts() {
	# 移除全部脚本
	rm minecraft/start.sh minecraft/stop.sh minecraft/restart.sh
	
	# 下载start.sh
	echo "下载start.sh ..."
	wget -O start.sh https://raw.githubusercontent.com/laomingOfficial/RaspberryPiMinecraft/master/start.sh
	chmod +x start.sh
	sed -i "s:memselect:$MemSelected:g" start.sh
	sed -i "s:dirminecraft:$DirMinecraft:g" start.sh
	
	# 下载stop.sh
	echo "下载stop.sh ..."
	wget -O stop.sh https://raw.githubusercontent.com/laomingOfficial/RaspberryPiMinecraft/master/stop.sh
	chmod +x stop.sh

	# 下载restart.sh
	echo "下载restart.sh ..."
	wget -O restart.sh https://raw.githubusercontent.com/laomingOfficial/RaspberryPiMinecraft/master/restart.sh
	chmod +x restart.sh
}

# 更新服务
Update_Service() {
	sudo wget -O /etc/systemd/system/minecraft.service https://raw.githubusercontent.com/laomingOfficial/RaspberryPiMinecraft/master/minecraft.service
	sudo chmod +x /etc/systemd/system/minecraft.service
	sudo sed -i "s/replace/$UserName/g" /etc/systemd/system/minecraft.service
	sudo sed -i "s:dirminecraft:$DirMinecraft:g" /etc/systemd/system/minecraft.service
	sudo systemctl daemon-reload
	echo "开机时是否自动开启Minecraft服务器？ (y/n)"
	read answer
	if [ "$answer" != "${answer#[Yy]}" ]; then
		sudo systemctl enable minecraft.service
	else
		sudo systemctl disable minecraft.service
	fi
}

Read_LatestMCVersion() {
	response=$(curl -s https://papermc.io/api/v1/paper)
	temp=${response#*'"versions":["'}
	latestVersion=${temp%%'"'*}
	response=$(curl -s https://papermc.io/api/v1/paper/$latestVersion/latest)
	temp=${response#*'"build":"'}
	buildVersion=${temp%%'"'*}
}

Update_LatestMC() {
	echo "开始下载Paper Minecraft server V${latestVersion}"
	wget -q -O /home/pi/minecraft/paperclip.jar https://papermc.io/api/v1/paper/${latestVersion}/latest/download
	echo "下载好啦"
}

Get_ServerMemory
Read_LatestMCVersion

# 提取home和username
DirName=$(readlink -e ~)
DirMinecraft=$DirName"/minecraft"
UserName=$(whoami)

# 如果文件夹存在，更新最新脚本
if [ -d $DirMinecraft ]; then
	echo "Minecraft文件夹存在"
	echo "如果要继续更新V${latestVersion} - Build${buildVersion}吗(minecraft会自动关闭)？ (y/n)"
	
	read answer
	
	if [ "$answer" != "${answer#[Yy]}" ]; then
		if screen -list | grep -q "minecraft"; then
			screen -Rd minecraft -X stuff "stop $(printf '\r')"
			sleep 15s
			echo "Minecraft服务器已关闭。"
			break
		fi
		
		cd minecraft
		Update_LatestMC
		Update_Scripts
		Update_Service
		
		echo "Minecraft脚本更新好啦... .____."
	fi
	
	exit 0
fi

echo "重新获取软件包列表 。。。"
sudo apt-get update

echo "安装Java OpenJDK 11。。。"
sudo apt-get install openjdk-11-jre-headless -y

echo "安装screen。。。 "
sudo apt-get install screen -y

echo "创建minecraft服务器文件夹。。。"
mkdir $DirMinecraft
cd $DirMinecraft

Update_LatestMC

echo "构建Minecraft服务器。。。 "
java -jar -Xms800M -Xmx800M paperclip.jar

echo "接受EULA。。。 "
echo eula=true > eula.txt

Update_Scripts
Update_Service

echo "输入你的Minecraft服务器名称 "
read -p '服务器名称: ' servername
echo "server-name=$servername" >> server.properties
echo "motd=$servername" >> server.properties

echo "服务器设置完成。进入minecraft服务器目录，然后输入./start.sh 开启服务器"
echo "如果要开放外网的话，记得在路由器设置端口转发(port forwarding)，端口: 25565"
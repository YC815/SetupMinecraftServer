#!/bin/bash
# James Chambers - V1.0 - March 24th 2018
# Marc Tönsing - V1.2 - September 16th 2019
# 老明 - V1.9 - May 23th 2020
# 老明 - V1.91 - Jun 15th 2020
# 参考Tuning the JVM – G1GC Garbage Collector Flags for Minecraft
# https://aikar.co/2018/07/02/tuning-the-jvm-g1gc-garbage-collector-flags-for-minecraft/
# 犽YC815 翻譯
echo "正在啟動Minecraft伺服器。 輸入screen -r minecraft進入伺服器終端機"
echo "要讓伺服器在背景運行，按Ctrl+A 和 Ctrl+D"
cd dirminecraft
/usr/bin/screen -dmS minecraft /usr/bin/java -jar -XmsmemselectM -XmxmemselectM  -XX:+UseG1GC -XX:+ParallelRefProcEnabled -XX:MaxGCPauseMillis=200 -XX:+UnlockExperimentalVMOptions -XX:+DisableExplicitGC -XX:+AlwaysPreTouch -XX:G1NewSizePercent=30 -XX:G1MaxNewSizePercent=40 -XX:G1HeapRegionSize=8M -XX:G1ReservePercent=20 -XX:G1HeapWastePercent=5 -XX:G1MixedGCCountTarget=4 -XX:InitiatingHeapOccupancyPercent=15 -XX:G1MixedGCLiveThresholdPercent=90 -XX:G1RSetUpdatingPauseTimePercent=5 -XX:SurvivorRatio=32 -XX:+PerfDisableSharedMem -XX:MaxTenuringThreshold=1 -Dusing.aikars.flags=https://mcflags.emc.gs -Daikars.new.flags=true -jar paperclip.jar nogui
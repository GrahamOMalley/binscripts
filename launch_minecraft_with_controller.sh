#! /bin/bash


mcj='/home/gom/downloads/minecraft.jar'

# if xboxdrv is running, kill it
if [ "$(pidof xboxdrv)" ] 
then
      killall xboxdrv
fi

# launch xboxdrv with the mouse/keyboard config
xboxdrv --ui-clear --trigger-as-button --ui-buttonmap A=KEY_B,Y=XK_f,B=XK_i,X=XK_q,rb=XK_p,rt=BTN_RIGHT,lt=BTN_LEFT,du=REL_WHEEL:1,dd=REL_WHEEL:-1,start=XK_Escape,select=XK_F11 --ui-axismap x1=KEY_A:KEY_D,y1=KEY_W:KEY_S,x2=REL_X:10,y2=REL_Y:10 --deadzone 8000 --silent --wid 0 -l 2 --detach-kernel-driver &

# fullscreen on startup, cant find -f option or equivalent
#/usr/lib/jvm/java-6-openjdk/bin/java -jar $mcj
/usr/bin/java -jar $mcj

# kill xboxdrv and restart controller 1 and 2 with their scripts
killall xboxdrv
/home/gom/bin/controller_1_start.sh
/home/gom/bin/controller_2_start.sh

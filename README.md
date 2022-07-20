## Sourcemod QQBot Library
You should compile qqbot.sp and put qqbot.smx to ```addons/sourcemod/plugins/```, then write your own qqbot.  
Dependence: [ripext](https://forums.alliedmods.net/showthread.php?t=298024)  
Example:
```
#include <sourcemod>
#include <qqbot>

public Plugin myinfo =
{
    name = "qqbot_demo",
    author = "cialloo",
    description = "a demo for my qq bot library",
    version = "1.0",
    url = "cialloo.com"
};

public void OnPluginStart()
{
    MessageToQQGroup("0721", "Ciallo~"); // 向群号为0721的qq群发送纯文字信息Ciallo~
    MessageToQQGroup("5201314", "I love u\nThis is another line"); // 向群号为5201314的qq群发送两行纯文字信息, 第一行是I love u, 第二行是This is another line
}
```
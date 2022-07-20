#include <sourcemod>
#include <ripext>

bool g_isBotVerify = false;
char g_qqnumber[64];
char g_host[64];
char g_verifykey[64];
char g_session[64];

public Plugin myinfo =
{
    name = "qqbot",
    author = "cialloo",
    description = "qqbot library",
    version = "1.0",
    url = "cialloo.com"
};

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	CreateNative("MessageToQQGroup", Native_MessageToQQGroup);
	return APLRes_Success;
}

public void OnPluginStart()
{
    CreateConVar("cialloo_qqbot_number", "07215201314");
    CreateConVar("cialloo_qqbot_host", "http://cialloo.com:8080");
    CreateConVar("cialloo_qqbot_verifykey", "verifykey");
    AutoExecConfig(true, "qqbot", "cialloo");
}

public void OnConfigsExecuted()
{
    if(g_isBotVerify)
        return;

    ConVar cialloo_qqbot_number = FindConVar("cialloo_qqbot_number"),
           cialloo_qqbot_host = FindConVar("cialloo_qqbot_host"),
           cialloo_qqbot_verifykey = FindConVar("cialloo_qqbot_verifykey");

    cialloo_qqbot_number.GetString(g_qqnumber, sizeof(g_qqnumber));
    cialloo_qqbot_host.GetString(g_host, sizeof(g_host));
    cialloo_qqbot_verifykey.GetString(g_verifykey, sizeof(g_verifykey));

    BotVerify();
}

public void OnPluginEnd()
{
    JSONObject json = new JSONObject();
    json.SetString("sessionKey", g_session);
    json.SetInt64("qq", g_qqnumber);

    char buffer[128];
    FormatEx(buffer, sizeof(buffer), "%s/release", g_host);
    HTTPRequest request = new HTTPRequest(buffer);
    request.Post(json, OnReleaseCallback);

    delete json;
}

stock void BotVerify()
{
    JSONObject json = new JSONObject();
    json.SetString("verifyKey", g_verifykey);

    char buffer[128];
    FormatEx(buffer, sizeof(buffer), "%s/verify", g_host);
    HTTPRequest request = new HTTPRequest(buffer);
    request.Post(json, OnVerifyCallback);

    delete json; 
}

void OnReleaseCallback(HTTPResponse response, any value)
{
    if (response.Status != HTTPStatus_OK) 
    {
        LogE("Error occur in OnReleaseCallback");
        return;
    }
}

void OnVerifyCallback(HTTPResponse response, any value)
{
    if (response.Status != HTTPStatus_OK) 
    {
        LogE("Error occur in OnVerifyCallback");
        return;
    }

    JSONObject json = view_as<JSONObject>(response.Data);
    if(json.GetInt("code") != 0)
    {
        LogE("Verify failed.");
        g_isBotVerify = false;
        return;
    }

    json.GetString("session", g_session, sizeof(g_session));

    JSONObject bind = new JSONObject();
    bind.SetString("sessionKey", g_session);
    bind.SetInt64("qq", g_qqnumber);

    char buffer[128];
    FormatEx(buffer, sizeof(buffer), "%s/bind", g_host);
    HTTPRequest request = new HTTPRequest(buffer);
    request.Post(bind, OnBindCallback);

    delete bind; 
}

void OnBindCallback(HTTPResponse response, any value)
{
    if (response.Status != HTTPStatus_OK) 
    {
        LogE("Error occur in OnBindCallback");
        return;
    }

    JSONObject json = view_as<JSONObject>(response.Data);
    if(json.GetInt("code") != 0)
    {
        LogE("Bind failed.");
        g_isBotVerify = false;
        return;
    }
    else
    {
        g_isBotVerify = true;
    }
}

stock void SendMessageToQQGroup(char[] group_number, char[] message)
{
    JSONObject json = new JSONObject();
    JSONObject messageJson = new JSONObject();
    JSONArray messageChain = new JSONArray();
    messageJson.SetString("type", "Plain");
    messageJson.SetString("text", message);
    messageChain.Push(messageJson);
    json.SetString("sessionKey", g_session);
    json.SetInt64("target", group_number);
    json.Set("messageChain", messageChain);

    char buffer[128];
    FormatEx(buffer, sizeof(buffer), "%s/sendGroupMessage", g_host);
    HTTPRequest request = new HTTPRequest(buffer);
    request.Post(json, OnSendMessageToGroup);

    delete messageJson;
    delete messageChain;
    delete json;
}

void OnSendMessageToGroup(HTTPResponse response, any value)
{
    if (response.Status != HTTPStatus_OK) 
    {
        LogE("Error occur in OnSendMessageToGroup");
        return;
    }
}

stock void LogE(char[] message)
{
    PrintToServer(message);
    LogError(message);
}

any Native_MessageToQQGroup(Handle plugin, int numParams)
{
    char message[1024], group_number[32];
    GetNativeString(1, group_number, sizeof(group_number));
    GetNativeString(2, message, sizeof(message));
    SendMessageToQQGroup(group_number, message);
}
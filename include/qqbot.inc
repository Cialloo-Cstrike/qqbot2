/** Double-include prevention */
#if defined _qqbot_included_
  #endinput
#endif
#define _qqbot_included_

native void MessageToQQGroup(char[] group_number, char[] message);
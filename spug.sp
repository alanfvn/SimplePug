#pragma semicolon 1
#pragma newdecls required

#include <sourcemod>
#include <sdktools>
#include "pug/util.inc"

int countdown = 5;

public Plugin myinfo = {
	name = "SimplePug",
	author = "alanfvn",
	description = "Simple and plain pug plugin.",
	version = "0.0.1",
	url = "https://github.com/alanfvn"
};

//EVENTS
public void OnPluginStart(){
	//event hooks.
	HookEvent("cs_win_panel_match", Event_MatchOver);
	HookEvent("server_cvar", Event_CvarChanged, EventHookMode_Pre); 
	//commands
	RegAdminCmd("sm_start", Command_Start, ADMFLAG_GENERIC, "Start the match");
	RegAdminCmd("sm_stop", Command_Stop, ADMFLAG_GENERIC, "Stop the match");
}

public void OnMapStart(){
	StartWarmup(true);
	ExecuteConfigs();
}

public Action Event_MatchOver(Event event, const char[] name, bool dontBroadcast){
	SetGameState(LOBBY);
	return Plugin_Continue;
}

public Action Event_CvarChanged(Event event, const char[] name, bool dontBroadcast) {
	event.BroadcastDisabled = true;
	return Plugin_Continue;
}

//COMMANDS
public Action Command_Start(int client, int args){
	if(GameInProgress()){
		PrintToChat(client, "Game is already in progress!");
		return Plugin_Handled;
	}
	PrintToChat(client, "Starting the game...");
	SetGameState(IN_GAME);
 	CreateTimer(1.0, Countdown, _, TIMER_REPEAT | TIMER_FLAG_NO_MAPCHANGE);
	return Plugin_Handled;
}

public Action Command_Stop(int client, int args){
	if(!GameInProgress()){
		PrintToChat(client, "Game is not in progress!");
		return Plugin_Handled;
	}
	StopGame();
	return Plugin_Handled;
}

//CALLBACKS
public Action Countdown(Handle value){
	if(countdown <= 0){
		StartGame();
		return Plugin_Stop;
	}
	if(countdown % 5 == 0 || countdown < 5){
		PrintToChatAll(" \x0E[L7] Starting in %d...", countdown);
	}
	countdown--;
	return Plugin_Handled;
}

//OTHER METHODS
public void StartGame(){
	ExecuteConfigs();
	EndWarmup();
}

public void StopGame(){
	SetGameState(LOBBY);
	ExecuteConfigs();
	StartWarmup(true);
	countdown = 5;
}
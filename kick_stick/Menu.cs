using UnityEngine;
using Harmony;
using System.Collections;

namespace KickStick {

	[HarmonyPatch(typeof(UnityEngine.PostProcessing.PostProcessingBehaviour))]
	[HarmonyPatch("OnGUI")]
	class MaksGUI {

		private static ChatManager mChat = null;
		private static MultiplayerManager mMultiManage = null;

		static bool Prefix() {

			if ( !(MatchmakingHandler.Instance.IsInsideLobby && MultiplayerManager.IsServer && PauseManager.isPaused) )
				return true;

			if (mChat == null)
				mChat = UnityEngine.Object.FindObjectOfType<ChatManager>();

			if (mMultiManage == null)
				mMultiManage = UnityEngine.Object.FindObjectOfType<MultiplayerManager>();

			GUI.Box(new Rect(10, 10, 200, mMultiManage.GetPlayersInLobby() * 40 + 20), "Maks' Kick Menu");

			ushort offset = 0;
			for (ushort i = 0; i < 4; ++i) {
				if (mMultiManage.ConnectedClients[i] == null || !mMultiManage.ConnectedClients[i].ClientID.IsValid())
					continue;

				if (GUI.Button(new Rect(20, 30 + (++offset) * 40, 180, 30), mMultiManage.ConnectedClients[i].PlayerName)) {

					mChat.Talk("Kicked " + mMultiManage.ConnectedClients[i].PlayerName);

					mMultiManage.KickPlayer(i, MultiplayerManager.KickResponse.IdleTooLong);
				}
			}

			return true;
		}
	}

}
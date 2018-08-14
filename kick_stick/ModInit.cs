using Harmony;
using UnityEngine;
using System.Reflection;

namespace KickStick {

	internal class ModInit : Partiality.Modloader.PartialityMod {

		public override void Init() {

			try {

				var harmony = HarmonyInstance.Create("maks.adminstick.stickfight");
				harmony.PatchAll(Assembly.GetExecutingAssembly());

			} catch (System.Exception e) {

				Debug.LogError(e.ToString());

			}
		}
	}
}
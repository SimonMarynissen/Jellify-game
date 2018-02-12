package org.bonuslevel {
	
	public class Hack {
		
		public static var LvlManager:Class;
		
		public static function getLvlsData():Object {
			return Main.Global.lvlManager["lvlsData"];
		}
		
		public static function getPackLvls():Object {
			return (Main.Global.lvlManager["packLvls"])[Main.Global.lvlManager["curPlayBrowsingCat"]];
		}
		
		public static function getOffset():int {
			return Main.Global.lvlManager["curOffLvlPage"] * LvlManager["NB_OF_PER_PAGE"];
		}
	}
}
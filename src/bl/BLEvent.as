package bl {
	
	import flash.events.Event;

	/**
	 * BL manager files rewritten to properly work with FlashDevelop.
	 * @author Jean-Philippe Sarda
	 * @edited Simon Marynissen
	 */
	
	public class BLEvent extends flash.events.Event {
		
		public static const CONTROL_TYPE:String = "BonusLevel";	
		public var
			command:String,
			cursorOverGUI:Boolean;
		
		public function BLEvent(command:String, cursorOverGUI:Boolean ) {
			super(CONTROL_TYPE);
			this.command = command;
			this.cursorOverGUI = cursorOverGUI;
		}
	}
}
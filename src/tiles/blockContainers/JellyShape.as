package tiles.blockContainers {
	
	import tiles.Block;

	public class JellyShape {
		
		private var
			jellies:/*Jelly*/Array = [];
		
		public function JellyShape(jelly:Jelly = null) {
			if (jelly != null)
				jellies.push(jelly);
		}
		
		public function setReadyToMove(ready:Boolean):void {
			for each (var jelly:Jelly in jellies) {
				for each (var block:Block in jelly.getBlocks()) {
					if (block.isReadyToMove() != ready)
						block.setReadyToMove(ready);
				}
			}
		}
		
		public function setReadyToFall(falling:Boolean):void {
			for each (var jelly:Jelly in jellies) {
				for each (var block:Block in jelly.getBlocks()) {
					if (block.isReadyToFall() != falling)
						block.setReadyToFall(falling);
				}
			}
		}
		
		public function mergeWith(other:JellyShape):void {
			if (this == other)
				return;
			var otherJellies:Array = other.getJellies();
			for each (var jelly:Jelly in otherJellies) {
				jellies.push(jelly);
				jelly.setJellyShape(this);
			}
		}
		
		public function add(jelly:Jelly):void {
			mergeWith(jelly.getJellyShape());
		}
		
		public function cloneAdd(jelly:Jelly):void {
			jellies.push(jelly);
			jelly.setJellyShape(this);
		}
		
		public function remove(jelly:Jelly):void {
			var index:int = jellies.indexOf(jelly);
			if (index != -1)
				jellies.splice(index, 1);
		}
		
		public function hasLockedBlocks():Boolean {
			for each (var jelly:Jelly in jellies) {
				if (jelly.hasLocked())
					return true;
			}
			return false;
		}
		
		public function getColours():Array {
			var colours:Array = [];
			for each (var jelly:Jelly in jellies)
				colours.push(jelly.getColour());
			return colours;
		}
		
		public function getJellies():Array { return this.jellies; }
	}
}
package gui {
	
	import flash.display.Sprite;

	public class OptionPanel extends Sprite {
		
		private var
			musicVolume:Number,
			effectVolume:Number;
		
		public function OptionPanel(musicVolume:Number, effectVolume:Number) {
			this.musicVolume = musicVolume;
			this.effectVolume = effectVolume;
		}
		
		public function getMusicVolume():Number { return this.musicVolume; }
		public function setMusicVolume(volume:Number):void {
			musicVolume = volume;
			Main.soundPlayer.changeMusicVolume(volume);
		}
		public function getEffectVolume():Number { return this.effectVolume; }
		public function setEffectVolume(volume:Number):void {
			effectVolume = volume;
			Main.soundPlayer.changeEffectVolume(volume);
		}
	}
}
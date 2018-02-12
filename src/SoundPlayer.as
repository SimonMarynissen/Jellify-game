package {
	
	import flash.events.Event;
	import flash.media.Sound;
	import flash.media.SoundChannel;
	import flash.media.SoundMixer;
	import flash.media.SoundTransform;

	public class SoundPlayer {
		
		private var
			musicSoundChannel:SoundChannel= new SoundChannel(),
			musicSoundTransform:SoundTransform = new SoundTransform(1, 0),
			musics:/*Sound*/Array = [],
			musicPosition:Number = 0,
			musicIndex:int = 0,
			effectSoundChannel:SoundChannel = new SoundChannel(),
			effectSoundTransform:SoundTransform = new SoundTransform(1, 0),
			effects:/*Sound*/Array = [];
		
		public function SoundPlayer() { }
		
		public function addMusic(music:Sound):void {
			musics.push(music);
		}
		
		public function changeMusic(index:int):void {
			musicIndex = index;
			musicPosition = 0;
		}
		
		public function resumeMusic():void {
			if (musicPosition >= musics[musicIndex].length)
				musicPosition = 0;
			musicSoundChannel = musics[musicIndex].play(musicPosition);
			musicSoundChannel.soundTransform = musicSoundTransform;
			musicSoundChannel.addEventListener(Event.SOUND_COMPLETE, loop);
		}
		
		public function stopMusic():void {
			if (musicSoundChannel.hasEventListener(Event.SOUND_COMPLETE))
				musicSoundChannel.removeEventListener(Event.SOUND_COMPLETE, loop);
			musicPosition = musicSoundChannel.position;
			musicSoundChannel.stop();
		}
		
		public function changeMusicVolume(volume:Number):void {
			musicSoundTransform.volume = volume;
		}
		
		public function addEffect(effect:Sound):void {
			effects.push(effect);
		}
		
		public function playEffect(index:int):void {
			effectSoundChannel = effects[index].play();
			effectSoundChannel.soundTransform = effectSoundTransform;
		}
		
		public function changeEffectVolume(volume:Number):void {
			effectSoundTransform.volume = volume;
		}
		
		public function stopAllSounds():void {
			SoundMixer.stopAll();
		}
		
		private function loop(e:Event):void {
			musicPosition = 0;
			musicSoundChannel = musics[musicIndex].play(musicPosition);
			musicSoundChannel.soundTransform = musicSoundTransform;
		}
		
		public function hasMusic():Boolean {
			return musics.length != 0;
		}
	}
}
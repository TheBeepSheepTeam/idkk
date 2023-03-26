package;

/*
	Aw hell yeah! something I can actually work on!
 */
import flixel.FlxG;
import flixel.graphics.FlxGraphic;
import flixel.graphics.frames.FlxAtlasFrames;
import lime.utils.Assets;
import objects.CharacterData;
import openfl.display.BitmapData;
import openfl.display3D.textures.Texture;
import openfl.media.Sound;
import openfl.system.System;
import openfl.utils.AssetType;
import openfl.utils.Assets;
import sys.FileSystem;
import sys.io.File;

class Paths
{
	public static final SOUND_EXT = ['ogg', 'wav', 'mp3', 'flac'];

	public static final scriptExts = ['hx', 'hxs', 'hscript', 'hxc'];

	public static var currentTrackedAssets:Map<String, FlxGraphic> = [];
	public static var currentTrackedSounds:Map<String, Sound> = [];

	public static var localTrackedAssets:Array<String> = [];

	public static function excludeAsset(key:String)
	{
		if (!dumpExclusions.contains(key))
			dumpExclusions.push(key);
	}

	public static var dumpExclusions:Array<String> = [
		returnSound('music/freakyMenu'),
		returnSound('music/foreverMenu'),
		returnSound('music/breakfast'),
	];

	public static function clearUnusedMemory()
	{
		for (key in currentTrackedAssets.keys())
		{
			if (!localTrackedAssets.contains(key) && key != null)
			{
				var obj = currentTrackedAssets.get(key);
				@:privateAccess
				if (obj != null)
				{
					Assets.cache.removeBitmapData(key);
					Assets.cache.clearBitmapData(key);
					Assets.cache.clear(key);
					FlxG.bitmap._cache.remove(key);
					obj.destroy();
					currentTrackedAssets.remove(key);
				}
			}
		}

		for (key in currentTrackedSounds.keys())
		{
			if (!localTrackedAssets.contains(key) && key != null)
			{
				var obj = currentTrackedSounds.get(key);
				if (obj != null)
				{
					Assets.cache.removeSound(key);
					Assets.cache.clearSounds(key);
					Assets.cache.clear(key);
					currentTrackedSounds.remove(key);
				}
			}
		}
	}

	public static function clearStoredMemory()
	{
		@:privateAccess
		for (key in FlxG.bitmap._cache.keys())
		{
			var obj = FlxG.bitmap._cache.get(key);
			if (obj != null && !currentTrackedAssets.exists(key))
			{
				Assets.cache.removeBitmapData(key);
				Assets.cache.clearBitmapData(key);
				Assets.cache.clear(key);
				FlxG.bitmap._cache.remove(key);
				obj.destroy();
			}
		}

		@:privateAccess
		for (key in Assets.cache.getSoundKeys())
		{
			if (key != null && !currentTrackedSounds.exists(key))
			{
				var obj = Assets.cache.getSound(key);
				if (obj != null)
				{
					Assets.cache.removeSound(key);
					Assets.cache.clearSounds(key);
					Assets.cache.clear(key);
				}
			}
		}

		localTrackedAssets = [];
	}

	inline static public function txt(key:String):String
		return 'assets/$key.txt';

	inline static public function xml(key:String):String
		return 'assets/$key.xml';

	inline static public function json(key:String):String
		return 'assets/$key.json';

	inline static public function module(key:String):String
	{
		for (i in scriptExts)
		{
			if (Assets.exists('assets/$key.$i', TEXT))
			{
				return 'assets/$key.$i';
			}
			else
			{
				return 'assets/$key.hx';
			}
		}
	}

	inline static public function frag(key:String):String
		return 'assets/$key.frag';

	inline static public function vert(key:String):String
		return 'assets/$key.vert';

	inline static public function video(key:String):String
		return 'assets/$key.mp4';

	inline static public function font(key:String):String
		return 'assets/fonts/$key';

	static public function sound(key:String, ?cache:Bool = true):Sound
		return returnSound('sounds/$key', cache);

	inline static public function music(key:String, ?cache:Bool = true):Sound
		return returnSound('music/$key', cache);

	inline static public function voices(song:String, ?cache:Bool = true):Sound
		return returnSound('songs/' + formatName(song) + '/Voices', cache);

	inline static public function inst(song:String, ?cache:Bool = true):Sound
		return returnSound('songs/' + formatName(song) + '/Inst', cache);

	inline static public function image(key:String, ?cache:Bool = true):FlxGraphic
		return returnGraphic('images/$key', cache);

	inline static public function getSparrowAtlas(key:String, ?cache:Bool = true):FlxAtlasFrames
		return FlxAtlasFrames.fromSparrow(returnGraphic('images/$key', cache), xml('images/$key'));

	inline static public function getPackerAtlas(key:String, ?cache:Bool = true):FlxAtlasFrames
		return FlxAtlasFrames.fromSpriteSheetPacker(returnGraphic('images/$key', cache), txt('images/$key'));

	inline static public function formatName(name:String):String
		return name.replace(' ', '-').toLowerCase();

	public static function returnGraphic(key:String, ?cache:Bool = true):FlxGraphic
	{
		var path:String = 'assets/$key.png';
		if (Assets.exists(path, IMAGE))
		{
			if (!currentTrackedAssets.exists(path))
			{
				var graphic:FlxGraphic = FlxGraphic.fromBitmapData(Assets.getBitmapData(path), false, path, cache);
				graphic.persist = true;
				currentTrackedAssets.set(path, graphic);
			}

			localTrackedAssets.push(path);
			return currentTrackedAssets.get(path);
		}

		trace('$key its null');
		return null;
	}

	public static function returnSound(key:String, ?cache:Bool = true):Sound
	{
		for (i in SOUND_EXT) {
			if (Assets.exists('assets/$key.$i', SOUND))
			{
				var path:String = 'assets/$key.$i';
				if (!currentTrackedSounds.exists(path))
					currentTrackedSounds.set(path, Assets.getSound(path, cache));

				localTrackedAssets.push(path);
				return currentTrackedSounds.get(path);
			}
		}

		trace('$key its null');
		return null;
	}

	inline static public function characterModule(folder:String, character:String, ?type:CharacterOrigin)
	{
		var extension:String = '';

		if (folder == null)
			folder = 'placeholder';

		if (character == null)
			character = 'placeholder';

		switch (type)
		{
			case PSYCH_ENGINE:
				extension = '.json';
			case FOREVER_FEATHER:
				for (j in scriptExts)
				{
					if (FileSystem.exists('data/characters/$folder/$character.$j', TEXT))
						extension = '.$j';
					else
						extension = '.hx';
				}
				extension = '.hx';
			case FUNKIN_COCOA:
				extension = '.yaml';
			default:
				extension = '';
		}
		return getPath('data/characters/$folder/$character' + extension, TEXT);
	}
}

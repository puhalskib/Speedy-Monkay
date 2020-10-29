package;

//import flixel.addons.tile.FlxTilemapExt;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.text.FlxText;
import flixel.tile.FlxTilemap;
import flixel.system.FlxSound;
import flixel.group.FlxGroup;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import flixel.util.FlxGradient;
import flixel.math.FlxPoint;
import openfl.Assets;

class PlayState extends FlxState
{
	var _map:FlxTilemap;
	var _monkey:Monkey;
	var _powerup:FlxSprite;

	var _txtInfo:FlxText;

	public var playerBananas:FlxTypedGroup<FlxSprite>;

	var _targets:FlxTypedGroup<FlxSprite>;
	var _targetNum:Int;

	var _pointSound:FlxSound;
	var _deathSound:FlxSound;

	var ending:Bool;

	var _level:Int;

	var _timer:Int;

	public function new(level:Null<Int>)
	{
		trace(level);
		if(level != null) {
			_level = level;
		} else {
			_level = 1;
		}
		super();
	}

	override public function create():Void
	{
		//bgColor = 0xff661166;
		var back:FlxSprite = FlxGradient.createGradientFlxSprite(FlxG.width, FlxG.height, [0xff6dcff6, 0xff333333], 16);
		back.scrollFactor.set();
		add(back);

		super.create();

		FlxG.mouse.visible = false;

		_map = new FlxTilemap();
		trace("assets/data/level" + _level + ".txt");
		_map.loadMapFromCSV("assets/data/level" + _level + ".txt", "assets/images/tiles.png", 16, 16);
		add(_map);

		_targets = new FlxTypedGroup(4);
		var locations:Array<Array<Int>> = [[360,264],[650,280],[900,248],[1200,280]];
		var target:FlxSprite;
		_targetNum = 4;
		for (i in 0...4) {
			target = new FlxSprite(locations[i][0], locations[i][1]);
			target.loadGraphic("assets/images/target.png", true, 16, 16);
			target.animation.add("break", [1,2],2);
			_targets.add(target);
		}
		add(_targets);

		// set platform tiles
		_map.setTileProperties(2, FlxObject.NONE, fallInClouds);

		// set land
		_map.setTileProperties(1, FlxObject.ANY);

		//set lava
		_map.setTileProperties(3, FlxObject.ANY, lavaCollide);

		_monkey = new Monkey(32, 100);
		_monkey.solid = true;
		add(_monkey);

		// instantiate bananas
		var numPlayerBananas:Int = 8;
		playerBananas = new FlxTypedGroup(numPlayerBananas);
		var sprite:FlxSprite;

		// Create 8 bananas for the monkey to recycle
		for (i in 0...numPlayerBananas)
		{
			// Instantiate a new bananas offscreen
			sprite = new Monkey.Banana(-100, -100);
			sprite.exists = false;
			// Add it to the group of bananas
			playerBananas.add(sprite);
		}

		add(playerBananas);

		// The world bounds need to be set for the collision to work properly
		FlxG.worldBounds.set(_map.x, _map.y, _map.width, _map.height);

		//camera properties
		FlxG.camera.follow(_monkey);
		FlxG.camera.zoom = 3;

		//add sound
		_pointSound = FlxG.sound.load(AssetPaths.point__wav);
		_deathSound = FlxG.sound.load(AssetPaths.death__ogg);
		_deathSound.persist = true;


		//add the timer
		_timer = 0;
	}

	override public function update(elapsed:Float):Void
	{
		FlxG.collide(_map, _monkey);
		FlxG.collide(_map, playerBananas, bananaSplat);
		FlxG.collide(_targets, playerBananas, bananaHit);

		if (FlxG.keys.justReleased.R)
		{
			FlxG.camera.flash(FlxColor.BLACK, .1, FlxG.resetState);
		} else if(FlxG.keys.justReleased.T) {
			trace(_monkey.x + " :: " + _monkey.y + "\n" + "");
		}

		_timer++;

		super.update(elapsed);
		if (ending) {
 	    	return;
 		}
	}

	function fallInClouds(Tile:FlxObject, Object:FlxObject):Void
	{
		if (FlxG.keys.anyPressed([DOWN, S]))
		{
			Tile.allowCollisions = FlxObject.NONE;
		}
		else if (Object.y >= Tile.y)
		{
			Tile.allowCollisions = FlxObject.CEILING;
		}
	}

	function lavaCollide(Tile:FlxObject, Object:FlxObject):Void
	{
		if(Object == _monkey) {
			//monkey splat
			_deathSound.play(true);
			ending = true;
			FlxG.camera.fade(FlxColor.BLACK, 0.33, false, doneFadeOut);
		}
	}

	function bananaSplat(map:FlxTilemap, banana:FlxSprite):Void
	{
		banana.exists = false;
	}

	function bananaHit(target:FlxSprite, banana:FlxSprite):Void 
	{
		target.animation.play("break");
		target.exists = false;
		banana.exists = false;
		_targetNum--;
		_pointSound.play(true);
		if(_targetNum == 0) {
			//end level
			FlxG.switchState(new MenuState(true, _level, timerParse(_timer)));
		}
	}

	 function doneFadeOut()
 	{
    	FlxG.switchState(new MenuState(false, 1, timerParse(_timer)));
 	}

 	function timerParse(i:Int):String
	{
		var frame = i%60;
		i = Math.floor(i / 60);
		var second = i%60;
		var minute = Math.floor(i/60);
		return "" + minute + ":" + second + "::" + frame;
	}

}
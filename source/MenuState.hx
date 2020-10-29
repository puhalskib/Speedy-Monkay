package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.text.FlxText;
import flixel.ui.FlxButton;
import flixel.util.FlxAxes;
import flixel.util.FlxColor;
import flixel.util.FlxSave;

class MenuState extends FlxState
{
	var level:Int = -2; // number level
	var win:Bool; // if we won or lost
	var time:String; // time on level
	var titleText:FlxText; // the title text
	var messageText:FlxText; // the final score message text
	var scoreText:FlxText; // text of the score
	var highscoreText:FlxText; // text to show the highscore
	var MenuButton1:FlxButton; // level buttons 
	var MenuButton2:FlxButton; 
	var MenuButton3:FlxButton; 
	var MenuButton4:FlxButton; // replay button

// which mode we are at, recording or replaying
	static var recording:Bool = false;
	static var replaying:Bool = false;
	/**
	 * Called from PlayState, this will set our win and score variables
	 * @param	win		true if the player beat the boss, false if they died
	 * @param	level   level number
	 * @param 	time    parsed time number; minute:second:frame
	 */
	public function new(win:Null<Bool>, level:Null<Int>, time:Null<String>)
	{
		super();
		if(win == null && level == null) {
			this.win = true;
			this.level = -2;
			this.time = "";
		} else {
			this.win = win;
			this.level = level;
			this.time = time;
		}
	}

	override public function create()
	{
		#if FLX_MOUSE
		FlxG.mouse.visible = true;
		#end

		// create and add each of our items
		if(level != -2) {
			titleText = new FlxText(0, 20, 0, if (win) ("Beat level " + level) else "Game Over!", 44);
			titleText.alignment = CENTER;
			titleText.screenCenter(FlxAxes.X);
			add(titleText);

			messageText = new FlxText(0, (FlxG.height / 2) - 18, 0, "Time: " + time, 22);
			messageText.alignment = CENTER;
			messageText.screenCenter(FlxAxes.X);
			add(messageText);

			scoreText = new FlxText((FlxG.width / 2), 0, 0, Std.string(level), 8);
			scoreText.screenCenter(FlxAxes.Y);
			add(scoreText);
		} else {
			titleText = new FlxText(0, (FlxG.height / 2) - 10, 0, "Speedy Monkay", 44);
			titleText.alignment = CENTER;
			titleText.screenCenter(FlxAxes.X);
			add(titleText);
		}
		MenuButton1 = new FlxButton(0*FlxG.width/4 + 30, FlxG.height - 32, "Level 1", switchToLevel1);
		MenuButton1.onUp.sound = FlxG.sound.load(AssetPaths.select__wav);
		add(MenuButton1);

		MenuButton2 = new FlxButton(1*FlxG.width/4 + 30, FlxG.height - 32, "Level 2", switchToLevel2);
		MenuButton2.onUp.sound = FlxG.sound.load(AssetPaths.select__wav);
		add(MenuButton2);

		MenuButton3 = new FlxButton(2*FlxG.width/4 + 30, FlxG.height - 32, "Level 3", switchToLevel3);
		MenuButton3.onUp.sound = FlxG.sound.load(AssetPaths.select__wav);
		add(MenuButton3);

		MenuButton4 = new FlxButton(3*FlxG.width/4 + 30, FlxG.height - 32, "Load Replay", switchToLoadReplay);
		MenuButton4.onUp.sound = FlxG.sound.load(AssetPaths.select__wav);
		add(MenuButton4);
		
		FlxG.camera.fade(FlxColor.BLACK, 0.33, true);

		//play music
		if (FlxG.sound.music == null) // don't restart the music if it's already playing
 		{
     		FlxG.sound.playMusic(AssetPaths.surf__ogg, 1, true);
 		}

		super.create();
	}

	override public function update(elapsed:Float):Void 
	{

		if (!recording && !replaying)
		{
			startRecording();
		}

		super.update(elapsed);
	}

	function startRecording():Void
	{
		recording = true;
		replaying = false;

		/**
		 * Note FlxG.recordReplay will restart the game or state
		 * This function will trigger a flag in FlxGame
		 * and let the internal FlxReplay to record input on every frame
		 */
		FlxG.vcr.startRecording(false);
	}


	function loadReplay():Void
	{
		replaying = true;
		recording = false;

		/**
		 * Here we get a string from stopRecoding()
		 * which records all the input during recording
		 * Then we load the save
		 */
		var save:String = FlxG.vcr.stopRecording(false);
		FlxG.vcr.loadReplay(save, new MenuState(true, -2, ""), ["ANY", "MOUSE"], 0, startRecording);
	}

	/**
	 * button select
	 */
	function switchToLevel1():Void
	{
		FlxG.camera.fade(FlxColor.BLACK, 0.33, false, function()
		{
			FlxG.switchState(new PlayState(1));
		});
	}
	function switchToLevel2():Void
	{
		FlxG.camera.fade(FlxColor.BLACK, 0.33, false, function()
		{
			FlxG.switchState(new PlayState(2));
		});
	}
	function switchToLevel3():Void
	{
		FlxG.camera.fade(FlxColor.BLACK, 0.33, false, function()
		{
			FlxG.switchState(new PlayState(3));
		});
	}
	function switchToLoadReplay():Void
	{
		loadReplay();
	}
}
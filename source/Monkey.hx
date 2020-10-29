package;

import flixel.addons.util.FlxFSM;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.util.FlxColor;

class Monkey extends FlxSprite
{
	public static inline var GRAVITY:Float = 600;

	public var fsm:FlxFSM<FlxSprite>;

	public function new(X:Float = 0, Y:Float = 0)
	{
		super(X, Y);

		loadGraphic("assets/images/monkey.png", true, 24, 24);
		setFacingFlip(FlxObject.LEFT, true, false);
		setFacingFlip(FlxObject.RIGHT, false, false);
		facing = FlxObject.RIGHT;

		animation.add("standing", [2]);
		animation.add("walking", [3, 4], 12);
		animation.add("jumping", [1]);
		animation.add("pound", [0]);
		animation.add("landing", [5], false);
		animation.add("throwing", [6,6], 6, false);
		animation.add("thrown", [7,7], 10, false);


		acceleration.y = GRAVITY;
		maxVelocity.set(200, GRAVITY);

		fsm = new FlxFSM<FlxSprite>(this);
		fsm.transitions.add(Idle, Jump, Conditions.jump)
			.add(Jump, InAir, Conditions.notGrounded)
			.add(Idle, InAir, Conditions.notGrounded)
			.add(InAir, Idle, Conditions.grounded)
			.add(InAir, DoubleJump, Conditions.doubleJump)
			.add(DoubleJump, Idle, Conditions.grounded)
			.add(Idle, DoubleJump, Conditions.doubleJump)
			.add(Idle, Throw, Conditions.throwing)
			.add(InAir, Throw, Conditions.throwing)
			.add(DoubleJump, Throw, Conditions.throwing)
			.add(Throw, BananaThrow, Conditions.animationFinished)
			.add(BananaThrow, Idle, Conditions.animationFinished)
			.add(Idle, Slide, Conditions.slide)
			.add(Slide, Idle, Conditions.grounded)
			.start(Idle);
	}

	override public function update(elapsed:Float):Void
	{
		fsm.update(elapsed);
		super.update(elapsed);
	}

	override public function destroy():Void
	{
		fsm.destroy();
		fsm = null;
		super.destroy();
	}
}

class Banana extends FlxSprite
{
	public static inline var GRAVITY:Float = 300;

	public function new(X:Float = 0, Y:Float = 0)
	{
		super(X, Y);

		loadGraphic("assets/images/banana.png", true, 8, 9);

		animation.add("spin", [0,1],3);

		acceleration.y = GRAVITY;

		animation.play("spin");
	}

	override public function update(elapsed:Float):Void
	{
		super.update(elapsed);

	}
}

class Conditions
{
	public static function jump(Owner:FlxSprite):Bool
	{
		return (FlxG.keys.justPressed.UP && Owner.isTouching(FlxObject.DOWN) && Owner.health == 2);
	}

	public static function grounded(Owner:FlxSprite):Bool
	{
		return Owner.isTouching(FlxObject.DOWN);
	}

	public static function slide(Owner:FlxSprite):Bool
	{
		return Owner.isTouching(FlxObject.DOWN) && FlxG.keys.justPressed.DOWN;
	}

	public static function notGrounded(Owner:FlxSprite):Bool
	{
		return !(Owner.isTouching(FlxObject.DOWN));
	}

	public static function animationFinished(Owner:FlxSprite):Bool
	{
		return Owner.animation.finished;
	}

	public static function doubleJump(Owner:FlxSprite):Bool
	{
		return (FlxG.keys.justPressed.UP);
	}

	public static function throwing(Owner:FlxSprite):Bool
	{
		return (FlxG.keys.justPressed.E);
	}
}

class Idle extends FlxFSMState<FlxSprite>
{
	var cooldown:Int;
	override public function enter(owner:FlxSprite, fsm:FlxFSM<FlxSprite>):Void
	{
		owner.animation.play("standing");
		cooldown = 20;
	}

	override public function update(elapsed:Float, owner:FlxSprite, fsm:FlxFSM<FlxSprite>):Void
	{
		owner.acceleration.x = 0;
		if (FlxG.keys.pressed.LEFT || FlxG.keys.pressed.RIGHT)
		{
			owner.facing = FlxG.keys.pressed.LEFT ? FlxObject.LEFT : FlxObject.RIGHT;
			owner.animation.play("walking");
			owner.acceleration.x = FlxG.keys.pressed.LEFT ? -300 : 300;
			if(owner.velocity.x > 100) {
				owner.velocity.x = 100;
			} else if(owner.velocity.x < -100) {
				owner.velocity.x = -100;
			}
		}
		else
		{
			owner.animation.play("standing");
			owner.velocity.x *= 0.9;
		}
		if(cooldown > 0) {
			cooldown--;
		} else {
			owner.health = 2;
		}

	}
}

class Jump extends FlxFSMState<FlxSprite>
{
	override public function enter(owner:FlxSprite, fsm:FlxFSM<FlxSprite>):Void
	{
		owner.animation.play("jumping");
		owner.velocity.y = -200;
		if(owner.facing == FlxObject.RIGHT) {
			owner.velocity.x = 200;
		} else {
			owner.velocity.x = -200;
		}
		owner.health = 1;
	}
}

class InAir extends FlxFSMState<FlxSprite>
{
	override public function enter(owner:FlxSprite, fms:FlxFSM<FlxSprite>):Void
	{
		owner.animation.play("jumping");
	}

	override public function update(elapsed:Float, owner:FlxSprite, fsm:FlxFSM<FlxSprite>):Void
	{
		owner.acceleration.x = 0;
		if (FlxG.keys.pressed.LEFT || FlxG.keys.pressed.RIGHT)
		{
			owner.acceleration.x = FlxG.keys.pressed.LEFT ? -300 : 300;
		}
	}
}

class Slide extends FlxFSMState<FlxSprite>
{
	override public function enter(owner:FlxSprite, fsm:FlxFSM<FlxSprite>):Void
	{
		owner.animation.play("landing");
		owner.velocity.y = -100;
		if(owner.facing == FlxObject.RIGHT) {
			owner.velocity.x = 160;
		} else {
			owner.velocity.x = -160;
		}
		owner.health = 2;
	}
}

class DoubleJump extends FlxFSMState<FlxSprite>
{
	override public function enter(owner:FlxSprite, fsm:FlxFSM<FlxSprite>):Void
	{
		owner.animation.play("pound");
		owner.velocity.y = -150;
	}
	override public function update(elapsed:Float, owner:FlxSprite, fsm:FlxFSM<FlxSprite>):Void
	{
		owner.acceleration.x = 0;
		if (FlxG.keys.pressed.LEFT || FlxG.keys.pressed.RIGHT)
		{
			owner.acceleration.x = FlxG.keys.pressed.LEFT ? -300 : 300;

		}
		if(owner.velocity.x > 60) {
			owner.velocity.x = 60;
		} else if(owner.velocity.x < -60) {
			owner.velocity.x = -60;
		}
	}
}

class Throw extends FlxFSMState<FlxSprite>
{
	override public function enter(owner:FlxSprite, fsm:FlxFSM<FlxSprite>):Void
	{
		owner.animation.play("throwing");
	}
	override public function update(elapsed:Float, owner:FlxSprite, fsm:FlxFSM<FlxSprite>):Void
	{
		owner.acceleration.x = 0;
	}
}

class BananaThrow extends Throw
{
	override public function enter(owner:FlxSprite, fsm:FlxFSM<FlxSprite>):Void
	{
		owner.animation.play("thrown");

		// FIRE A banana
		var playState:PlayState = cast FlxG.state;
		var banana:FlxSprite = playState.playerBananas.recycle();
		if(owner.facing == FlxObject.RIGHT) {
			banana.reset(owner.x + owner.width - 12, owner.y + 12);
			banana.velocity.x = 200;
		} else {
			banana.reset(owner.x+4, owner.y + 12);
			banana.velocity.x = -200;
		}
		banana.velocity.y = -140;

	}
}
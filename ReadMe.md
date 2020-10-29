# ReadMe

This program is a platformer designed around speed and completion times.

Ben Puhalski. CS 4478

# Features

- Replay system (full playthroughs)
- Animated sprites
- Music
- Sound effects
- Projectiles
- Targets
- Timer
- Level select
- Player State machine (FSM)
- Platformer Movement

# Design

## Inspiration

This program is designed for players who desire to master a complex movement system. The player's movement is inspired by Mario in his Super Mario 64 variant. When taking this inspiration, specifically referring to the dive. In Mario 64, when Mario lands he does an extra flip animation at the end which forces the player to plan ahead even before initiating the first dive to where Mario will end up after the extra flip.

The targets and timer and heavily inspired by target test from super smash brothers. The projectile is a form of investment and has startup and end lag just like moves in the smash series. The implementation specifically avoids any hitboxes without lag because that requires less thought and therefore is less interesting in my opinion.

The main monkey sprite is essentially taken from Yoshi's Island with some tweaks to the arms when moving and eyes when throwing.

## Implementation

The **state machine** is used by the player sprite because of the complex movement. 

<img src="D:\Documents\University\Game Programming\proj 1\statemachine.png" style="zoom: 50%;" />

Since the player controller only takes 5 digital inputs, it was easier to use a state machine to simplify code.



The **replay system** uses FlxG.vcr to record keyboard inputs. The replay system saves it to a string. The system can then load the replay and play it using the FlxState to play them, since HaxeFlixel is said to be relatively deterministic. 

The **banana projectiles** Use a FlxTypedGroup to bring projectiles in and out of existence since there will be a relatively low amount of projectiles existing at once, this is not a problem.  

```haxe
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
add(playerBananas)
```

Above sets up the bananas to be used by the monkey

```haxe
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
```

The above fires the banana.

## Problems

Many more features were planned but did not come in on time. 

- Serialize replays
- Load replays from files
- Level specific replays
  - This only was not possible since the PlayState used to load levels used new(level:Int) to load specific levels. Whenever a FlxG.vcr starts recording it instantiates a new FlxState with no arguments which in my case will default to level 1. 
- Wall jumping
- Enemies
- More levels
- etc...

# Player Experience

The player is meant to discover how to move with the monkey on their own to discover how to move the best themselves. However arrow keys left and right control horizontal speed. The **jump** (UP) state has a cooldown since it gives the monkey a boost in speed. The monkey has to be in **idle** for 20 frames or use a **slide** (DOWN) to be able to use **jump** again. Since this is a game designed around speed, a limitation is put on the monkey's best speed tool.

The monkey does have a **DoubleJump** however it is limited because it gains much less extra height and slows down the max horizontal velocity the monkey can move. This is designed so that tighter jumps are riskier but more rewarding in terms of speed. If the player tries to jump before the cooldown has ended and has not used slide, the monkey will perform this double jump.

The last things to be discovered is (E) throws bananas and (DOWN) to go through platforms as well as avoid the lava tiles.








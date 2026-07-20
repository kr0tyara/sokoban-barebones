package levels;

import avatars.LevelAvatar;
import h2d.Anim;
import motion.Actuate;

// You can implement custom logic for different levels.
// Specify className of the level in the spreadsheet, and a class for it will be generated automatically.

class SampleLevel extends Level
{
    private var tutorial:Anim;
    private var tutorialShown:Bool;
    private var moved:Bool;

    public function new()
    {
        super(Data.LevelsKind.level00);
    }
        
    public override function Init()
    {
        super.Init();

        // You can assign tags to individual objects by pressing E in CastleDB while hovering an object in the level. You can reference them in the code like this:
        var player = Level.grid.GetObjectByTag('me');

        // Focus the camera on the initial coordinates of the player
        Level.avatar.Focus({x: player.x - .5, y: player.y - .5, w: 2, h: 2});
        Actuate.timer(1).onComplete(() -> Level.avatar.Focus(null, true));
        
        // It's a bit hacky, but you can also do this:
        var extra = Level.grid.GetObjectByTag('tutorial');
        tutorial = new Anim(Main.sheet.Tutorial.frames.slice(0, 3));
        tutorial.x = extra.avatar.x + LevelAvatar.PixelsPerTile / 2;
        tutorial.y = extra.avatar.y + 10;

        tutorial.speed = 0;
        tutorial.alpha = 0;
        Level.avatar.extraContainer.addChild(tutorial);

        // Tutorial on how to move will only show if the player never moved within the first 3 seconds
        Actuate.timer(3).onComplete(() ->
        {
            if(!moved)
            {
                Actuate.tween(tutorial, .75, {alpha: 1}).onComplete(() -> {
                    tutorial.speed = 0.5;
                });
            }
        });
    }

    private override function OnMovementEnd(initial:Bool)
    {
        super.OnMovementEnd(initial);

        moved = true;
    }
}
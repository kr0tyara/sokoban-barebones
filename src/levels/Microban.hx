package levels;

import AudioManager.Sfx;
import motion.Actuate;
import avatars.LevelAvatar;
import h2d.Anim;

class Microban extends Level
{
    public function new()
    {
        super(Data.LevelsKind.level01);
    }
        
    public override function Init()
    {
        super.Init();
        
        var extra = Level.grid.GetObjectByTag('tutorial');
        var tutorial = new Anim(Main.sheet.Tutorial.frames.slice(3, 6));
        tutorial.x = extra.avatar.x + LevelAvatar.PixelsPerTile;
        tutorial.y = extra.avatar.y + LevelAvatar.PixelsPerTile - 15;

        tutorial.speed = 0.5;
        Level.avatar.extraContainer.addChild(tutorial);
    }

    // You can even customize win animation!
    public override function OnComplete()
    {
        var player = Level.grid.GetObjectByTag('player');
        Level.avatar.Focus({x: player.x, y: player.y, w: 1, h: 1}, true, .5,
            () -> {
                Actuate.timer(.25).onComplete(() -> {
                    player.avatar.visible = false;
                    AudioManager.inst.Play(Sfx.Pop);
                });   
            });

        super.Complete(1.5);
    }
}
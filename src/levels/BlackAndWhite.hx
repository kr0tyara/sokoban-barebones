package levels;

import motion.Actuate;
import AudioManager.Sfx;

class BlackAndWhite extends Level
{
    public function new()
    {
        super(Data.LevelsKind.level02);
    }
        
    public override function Init()
    {
        super.Init();

        Level.avatar.background.SetTile(hxd.Res.waterAlt.toTile());
    }

    public override function OnComplete()
    {
        Level.avatar.background.SetTile(hxd.Res.water.toTile(), true, .15, 2);

        Actuate.timer(.15).onComplete(() -> {
            AudioManager.inst.Play(Sfx.Unlock);
        });

        super.Complete(1.15);
    }
}
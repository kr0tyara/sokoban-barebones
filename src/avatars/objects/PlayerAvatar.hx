package avatars.objects;

import h2d.Anim;
import entities.objects.Player;

class PlayerAvatar extends ObjectAvatar
{
    private var anim:Anim;
    
    public function new(prototype:Player)
    {
        super(prototype);
    }

    public override function SpawnSprite()
    {
        spriteContainer.removeChildren();

        anim = new Anim(Main.sheet.Guy.frames);
        anim.currentFrame = 0;
        anim.speed = 4;
        anim.x = -2;
        anim.y = -4;
        spriteContainer.addChild(anim);
    
        Update();
    }
}
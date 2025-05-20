package avatars.objects;

import h2d.Anim;
import entities.objects.ObjectEntity;

class BlockAvatar extends ObjectAvatar
{
    private var anim:Anim;
    
    public function new(prototype:ObjectEntity)
    {
        super(prototype);
    }

    public override function SpawnSprite()
    {
        spriteContainer.removeChildren();

        anim = new Anim(Main.sheet.Wall.frames);
        anim.currentFrame = 0;
        anim.speed = 4;
        anim.x = -2;
        spriteContainer.addChild(anim);
    
        Update();
    }
}
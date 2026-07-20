package avatars.objects;

import h2d.Anim;
import entities.objects.ObjectEntity;

class InvisibleAvatar extends ObjectAvatar
{
    private var anim:Anim;
    
    public function new(prototype:ObjectEntity)
    {
        super(prototype);
    }

    public override function SpawnSprite()
    {
        spriteContainer.removeChildren();
        Update();
    }
}
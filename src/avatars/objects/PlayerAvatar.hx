package avatars.objects;

import h2d.Anim;
import entities.objects.Player;

class PlayerAvatar extends ObjectAvatar
{
    private var anim:Anim;
    private var player:Player;
    
    public function new(prototype:Player)
    {
        super(prototype);
        player = prototype;
    }

    public override function SpawnSprite()
    {
        spriteContainer.removeChildren();

        anim = new Anim((player.altSprite ? Main.sheet.GuyAlt : Main.sheet.Guy).frames);
        anim.currentFrame = 0;
        anim.speed = 4;
        anim.x = LevelAvatar.PixelsPerTile / 2;
        anim.y = LevelAvatar.PixelsPerTile + 8;
        spriteContainer.addChild(anim);
    
        Update();
    }
}
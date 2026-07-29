package entities.objects;

import avatars.objects.PlayerAvatar;

class Player extends ObjectEntity
{
    public var altSprite:Bool = false;

    // altSprite is assigned as one of customArguments
    public function new(kind:Data.ObjectsKind, altSprite:Bool = false)
    {
        super(kind);
        this.altSprite = altSprite;

        avatarClass = PlayerAvatar;
    }

    public override function CanPush(dirX:Int, dirY:Int, isPlayerMove:Bool):Bool
    {
        return isPlayerMove;
    }
}
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
}
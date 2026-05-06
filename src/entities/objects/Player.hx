package entities.objects;

import avatars.objects.PlayerAvatar;

class Player extends ObjectEntity
{
    public function new(kind:Data.ObjectsKind)
    {
        super(kind);
        avatarClass = PlayerAvatar;
    }
}
package entities.objects;

import avatars.objects.PlayerAvatar;

class Player extends ObjectEntity
{
    public function new()
    {
        super(Data.ObjectsKind.Player);
        avatarClass = PlayerAvatar;
    }
}
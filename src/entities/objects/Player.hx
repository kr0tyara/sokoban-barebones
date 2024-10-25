package entities.objects;

import avatars.objects.PlayerAvatar;
import entities.objects.ObjectEntity.ObjectType;

class Player extends ObjectEntity
{
    public function new()
    {
        super(ObjectType.Player);
        avatarClass = PlayerAvatar;
    }
}
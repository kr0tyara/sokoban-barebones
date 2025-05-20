package entities.objects;

import avatars.objects.BlockAvatar;
import entities.objects.ObjectEntity.ObjectType;

class Block extends ObjectEntity
{
    public function new()
    {
        super(ObjectType.Block);
        avatarClass = BlockAvatar;
    }
}
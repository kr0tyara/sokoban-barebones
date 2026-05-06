package entities.objects;

import avatars.objects.BlockAvatar;

class Block extends ObjectEntity
{
    public function new(kind:Data.ObjectsKind)
    {
        super(kind);
        avatarClass = BlockAvatar;
    }
}
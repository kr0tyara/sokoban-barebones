package entities.objects;

import avatars.objects.BlockAvatar;

class Block extends ObjectEntity
{
    public function new()
    {
        super(Data.ObjectsKind.Block);
        avatarClass = BlockAvatar;
    }
}
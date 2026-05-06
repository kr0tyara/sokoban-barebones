package entities.floors;

import avatars.floors.BasicAvatar;

class Basic extends FloorEntity
{
    public function new(kind:Data.FloorKind)
    {
        super(kind);
        avatarClass = BasicAvatar;
    }
}
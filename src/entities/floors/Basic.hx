package entities.floors;

import avatars.floors.BasicAvatar;

class Basic extends FloorEntity
{
    public function new()
    {
        super(Data.FloorKind.Basic);
        avatarClass = BasicAvatar;
    }
}
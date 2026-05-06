package entities.floors;

import avatars.floors.GoalAvatar;

class Goal extends FloorEntity
{
    public function new(kind:Data.FloorKind)
    {
        super(kind);
        avatarClass = GoalAvatar;
    }
}
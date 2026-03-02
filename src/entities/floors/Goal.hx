package entities.floors;

import avatars.floors.GoalAvatar;

class Goal extends FloorEntity
{
    public function new()
    {
        super(Data.FloorKind.Goal);
        avatarClass = GoalAvatar;
    }
}
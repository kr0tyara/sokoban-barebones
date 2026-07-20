package entities.objects;

import avatars.objects.InvisibleAvatar;

class Extra extends ObjectEntity
{
    public function new(kind:Data.ObjectsKind)
    {
        super(kind);

        this.avatarClass = InvisibleAvatar;
        this.invisible = true;
    }
}
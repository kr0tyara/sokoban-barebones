class TickGroup
{
    public function new()
    {
    }

    public function GetMembers()
    {
        var groupClass = Type.getClass(this);
        return Level.grid.GetAllEntities().filter(a -> a.followingTickGroups.contains(groupClass));
    }

    public function PreTick(initial:Bool)
    {
        var members = GetMembers();
        for(i in members)
            i.OnPreTick(initial);
    }
    public function Tick(initial:Bool)
    {
        var members = GetMembers();
        for(i in members)
            i.OnTick(initial);
    }
    public function PostTick(initial:Bool)
    {
        var members = GetMembers();
        for(i in members)
            i.OnPostTick(initial);
    }
}
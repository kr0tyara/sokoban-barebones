import tickGroups.*;

class TickQueue
{
    // you can use a custom tick order for all sorts of things.
    // in this project, MoverGroup is made for Movers so that
    // they only move stuff after everything else was moved by itself. 
    public var priorityQueue:Array<Class<TickGroup>> = 
    [
        DefaultGroup,
        MoverGroup
    ];
    private var queue:Map<Int, TickGroup> = [];

    public function new()
    {
    }

    public function Register(groupClass:Class<TickGroup>)
    {
        for(a in queue)
        {
            if(Type.getClass(a) == groupClass)
                return;
        }

        var index = priorityQueue.indexOf(groupClass);
        if(index == -1)
        {
            trace('cannot register group: ${Type.getClassName(groupClass)}: no order');
            return;
        }

        queue[index] = Type.createInstance(groupClass, []);
    }

    public function Tick(initial:Bool)
    {
        trace(queue);

        for(a in queue)
            a.PreTick(initial);
        
        for(a in queue)
            a.Tick(initial);

        for(a in queue)
            a.PostTick(initial);
    }
}
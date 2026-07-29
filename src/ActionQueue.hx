class ActionQueue
{
    public static var inst:ActionQueue;

    private var queue:Array<(done:()->Void)->Void> = [];
    private var waiting:Array<{condition:()->Bool, done:()->Void}> = [];

    private var running:Bool = false;
    private var wasBusy:Bool = false;

    public function new()
    {
        inst = this;
    }

    public var isBusy(get, never):Bool;
    function get_isBusy():Bool
    {
        return running || queue.length > 0 || waiting.length > 0;
    }

    public function Custom(run:(done:()->Void)->Void)
    {
        queue.push(run);
        UpdateBlockState();
        TryRunNext();
    }

    public function Do(action:()->Void)
    {
        Custom(done -> { action(); done(); });
    }

    public function Wait(seconds:Float, ?action:()->Void)
    {
        Custom(done ->
        {
            motion.Actuate.timer(seconds).onComplete(() ->
            {
                if(action != null)
                    action();

                done();
            });
        });
    }

    public function WaitUntil(condition:()->Bool, ?action:()->Void)
    {
        Custom(done ->
        {
            if(condition())
            {
                if(action != null)
                    action();

                done();
                return;
            }

            waiting.push({
                condition: condition,
                done: () ->
                {
                    if(action != null)
                        action();

                    done();
                }
            });
        });
    }

    public function Clear()
    {
        queue = [];
        waiting = [];
        running = false;

        UpdateBlockState();
    }

    private function TryRunNext()
    {
        if(running)
            return;

        if(queue.length == 0)
        {
            UpdateBlockState();
            return;
        }

        running = true;
        var next = queue.shift();

        next(() ->
        {
            running = false;
            UpdateBlockState();
            TryRunNext();
        });
    }

    public function update(dt:Float)
    {
        var i = waiting.length - 1;
        while(i >= 0)
        {
            if(waiting[i].condition())
            {
                var w = waiting[i];
                waiting.splice(i, 1);
                w.done();
            }

            i--;
        }

        UpdateBlockState();
    }

    private function UpdateBlockState()
    {
        var busy = isBusy;
        if(busy == wasBusy)
            return;

        wasBusy = busy;

        if(busy)
            InputManager.inst.Block();
        else
            InputManager.inst.Unblock();
    }
}

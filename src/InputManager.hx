import h3d.Vector;
import hxd.Event;
import hxd.Key;

enum InputKey
{
    None;
    Up;
    Down;
    Left;
    Right;
    Enter;
    Escape;
    X;
    Z;
    Y;
    R;
    B;
    N;
}

class Input
{
    public  var inputKey:InputKey;
    private var aliases:Array<Int>;

    public var lastPress:Float;
    public var hold:Bool;
    
    public var acceleratesOnHold:Bool = false;
    public var holdTime:Float = 0;
    public var originalRepeatInterval:Float = 0;

    public function new(inputKey:InputKey, aliases:Array<Int>, acceleratesOnHold:Bool = false)
    {
        this.inputKey = inputKey;
        this.aliases = aliases;
        this.acceleratesOnHold = acceleratesOnHold;

        lastPress = 0;
        hold = false;
    }

    public function IsDown():Bool
    {
        for(alias in aliases)
        {
            if(Key.isDown(alias))
                return true;
        }

        return false;
    }

    public function GetCurrentRepeatInterval(repeatDelay:Float, minRepeatInterval:Float, accelerationTime:Float):Float
    {
        if(!acceleratesOnHold || holdTime < repeatDelay)
            return originalRepeatInterval;

        var accelerationProgress = (holdTime - repeatDelay) / accelerationTime;
        accelerationProgress = Math.min(accelerationProgress, 1.0);

        var currentInterval = originalRepeatInterval - 
            (originalRepeatInterval - minRepeatInterval) * accelerationProgress;

        return currentInterval;
    }
}

class InputManager
{
    public static var inst:InputManager;

    private var repeatDelay:Float = 0.2;
    private var repeatInterval:Float = 0.2;
    private var minRepeatInterval:Float = 0.05;
    private var accelerationTime:Float = 1.0;

    public  var currentKey:InputKey = InputKey.None;
    private var inputs:Array<Input>;

    private var queue:Array<{ key:InputKey, time:Float }>;

    private var startPos:Vector = new Vector();
    private var inputPos:Vector = new Vector();
    private var isSwiping:Bool = false;
    private var wasSwiping:Bool = false;
    private var isClick:Bool = false;
    private var swipeThreshold:Float = 10;

    private var isBlocked:Bool = false;
    private var maxLifetime:Float = 1;

    public function new()
    {
        if(inst != null)
            return;

        inst = this;

        inputs = [];
        inputs.push(new Input(InputKey.Up, [Key.UP, Key.W]));
        inputs.push(new Input(InputKey.Down, [Key.DOWN, Key.S]));
        inputs.push(new Input(InputKey.Left, [Key.LEFT, Key.A]));
        inputs.push(new Input(InputKey.Right, [Key.RIGHT, Key.D]));
        inputs.push(new Input(InputKey.Enter, [Key.ENTER, Key.SPACE]));
        inputs.push(new Input(InputKey.Escape, [Key.ESCAPE]));
        inputs.push(new Input(InputKey.X, [Key.X, Key.SHIFT]));

        inputs.push(new Input(InputKey.Z, [Key.Z], true));
        inputs.push(new Input(InputKey.Y, [Key.Y], true));
        inputs.push(new Input(InputKey.R, [Key.R]));

        inputs.push(new Input(InputKey.B, [Key.B]));
        inputs.push(new Input(InputKey.N, [Key.N]));

        for(input in inputs)
            input.originalRepeatInterval = repeatInterval;

        queue = [];

        hxd.Window.getInstance().addEventTarget(OnEvent);
    }

    public function Block()
    {
        isBlocked = true;
    }

    public function Unblock()
    {
        isBlocked = false;
    }

    public function OnEvent(e:Event)
    {
        var focused = ui.Button.All.filter(a -> a.isOver()).length > 0;

        switch(e.kind)
        {
            case EventKind.EPush:
                if(focused)
                    return;

                startPos.x = inputPos.x = e.relX;
                startPos.y = inputPos.y = e.relY;
                isSwiping = true;

            case EventKind.EMove:
                if(focused)
                    return;
                
                if(isSwiping)
                {
                    inputPos.x = e.relX;
                    inputPos.y = e.relY;
                }

            case EventKind.ERelease:
                if(focused)
                    return;

                if(wasSwiping)
                    wasSwiping = false;
                else
                {
                    isClick = true;
                    isSwiping = false;
                }

            default:
        }
    }
    
    public function update(dt:Float)
    {
        HandleInput(dt);

        if(isSwiping)
        {
            var delta = new Vector(inputPos.x - startPos.x, inputPos.y - startPos.y);
            if(delta.length() >= swipeThreshold)
            {
                var direction:InputKey;
                if(Math.abs(delta.x) > Math.abs(delta.y))
                    direction = delta.x > 0 ? InputKey.Right : InputKey.Left;
                else
                    direction = delta.y > 0 ? InputKey.Down : InputKey.Up;

                queue.push({key: direction, time: 0.0});

                isSwiping = false;
                wasSwiping = true;
                inputPos = new Vector();
            }
        }
        else if(!wasSwiping && isClick)
        {
            queue.push({key: InputKey.Enter, time: 0.0});
            isClick = false;
        }
        
        var i = queue.length - 1;
        while(i >= 0)
        {
            queue[i].time += dt;

            if(queue[i].time > maxLifetime)
                queue.remove(queue[i]);

            i--;
        }

        if(isBlocked)
        {
            this.currentKey = InputKey.None;
            return;
        }
        
        if(queue.length > 0)
        {
            var element = queue.shift();
            this.currentKey = element.key;
        }
        else 
            this.currentKey = InputKey.None;
    }
    
    function HandleInput(dt:Float)
    {
        for(input in inputs)
        {
            if(input.IsDown())
            {
                input.holdTime += dt;

                if(!input.hold)
                {
                    queue.push({ key: input.inputKey, time: 0.0 });
                    input.hold = true;
                    input.lastPress = 0;
                }
                else
                {
                    var currentRepeatInterval = input.GetCurrentRepeatInterval(repeatDelay, minRepeatInterval, accelerationTime);
                    var lastPress = input.lastPress;
                    
                    if(lastPress >= repeatDelay)
                    {
                        queue.push({ key: input.inputKey, time: 0.0 });
                        input.lastPress -= currentRepeatInterval;
                    }
                    else
                        input.lastPress += dt;
                }
            }
            else
            {
                if(input.hold)
                    input.holdTime = 0;
                    
                input.hold = false;
            }
        }
    }
}
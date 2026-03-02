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

    public function new(inputKey:InputKey, aliases:Array<Int>)
    {
        this.inputKey = inputKey;
        this.aliases = aliases;

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
}

class InputManager
{
    public static var inst:InputManager;

    private var repeatDelay:Float = 0.2;
    private var repeatInterval:Float = 0.2;

    public  var currentKey:InputKey = InputKey.None;
    private var inputs:Array<Input>;
    private var queue:Array<InputKey>;

    private var startPos:Vector = new Vector();
    private var inputPos:Vector = new Vector();
    private var isSwiping:Bool = false;
    private var swipeThreshold:Float = 10;

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

        inputs.push(new Input(InputKey.Z, [Key.Z]));
        inputs.push(new Input(InputKey.Y, [Key.Y]));
        inputs.push(new Input(InputKey.R, [Key.R]));

        inputs.push(new Input(InputKey.B, [Key.B]));
        inputs.push(new Input(InputKey.N, [Key.N]));

        queue = [];

        hxd.Window.getInstance().addEventTarget(OnEvent);
    }

    public function OnEvent(e:Event)
    {
        switch(e.kind)
        {
            case EventKind.EPush:
                startPos.x = inputPos.x = e.relX;
                startPos.y = inputPos.y = e.relY;
                isSwiping = true;

            case EventKind.EMove:
                if(isSwiping)
                {
                    inputPos.x = e.relX;
                    inputPos.y = e.relY;
                }

            case EventKind.ERelease:
                isSwiping = false;

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

                this.currentKey = direction;

                isSwiping = false;
                inputPos = new Vector();

                return;
            }
        }
        
        if(queue.length > 0)
            this.currentKey = queue.shift();
        else 
            this.currentKey = InputKey.None;
    }
    
    function HandleInput(dt:Float)
    {
        for(input in inputs)
        {
            if(input.IsDown())
            {
                if(!input.hold)
                {
                    queue.push(input.inputKey);
                    input.hold = true;
                    input.lastPress = 0;
                }
                else
                {
                    var lastPress = input.lastPress;
                    if(lastPress >= repeatDelay)
                    {
                        queue.push(input.inputKey);
                        input.lastPress -= repeatInterval;
                    }
                    else
                        input.lastPress += dt;
                }
            }
            else
                input.hold = false;
        }
    }
}

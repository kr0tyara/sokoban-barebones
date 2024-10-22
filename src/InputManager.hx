import hxd.Key;

enum InputKey
{
    NONE;
    UP;
    DOWN;
    LEFT;
    RIGHT;
    Z;
    Y;
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
    public var inputBlocked:Bool;

    private var repeatDelay:Float = 0.33;
    private var repeatInterval:Float = 0.2;

    public  var currentKey:InputKey = InputKey.NONE;
    private var inputs:Array<Input>;
    private var queue:Array<InputKey>;

    public function new()
    {
        if(inst != null)
            return;

        inst = this;

        inputs = [];
        inputs.push(new Input(InputKey.UP, [Key.UP, Key.W]));
        inputs.push(new Input(InputKey.DOWN, [Key.DOWN, Key.S]));
        inputs.push(new Input(InputKey.LEFT, [Key.LEFT, Key.A]));
        inputs.push(new Input(InputKey.RIGHT, [Key.RIGHT, Key.D]));
        inputs.push(new Input(InputKey.Z, [Key.Z]));
        inputs.push(new Input(InputKey.Y, [Key.Y]));

        queue = [];
    }
    
    public function update(dt:Float)
    {
        HandleInput(dt);
        
        if(queue.length > 0)
            this.currentKey = queue.shift();
        else 
            this.currentKey = InputKey.NONE;
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

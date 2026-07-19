typedef IntVector = {
    x:Int,
    y:Int
}

class Utils
{
    
    public static function OppositeDir(dir:Dir)
    {
        switch(dir)
        {
            case Dir.Down:
                return Dir.Up;

            case Dir.Left:
                return Dir.Right;

            case Dir.Up:
                return Dir.Down;

            case Dir.Right:
                return Dir.Left;
        }

        return Dir.Up;
    }
    public static function VectorToDir(vec:IntVector):Dir
    {
        if(vec.x == 0 && vec.y < 0)
            return Dir.Up;

        if(vec.x == 0 && vec.y > 0)
            return Dir.Down;

        if(vec.y == 0 && vec.x < 0)
            return Dir.Left;

        if(vec.y == 0 && vec.x > 0)
            return Dir.Right;
        
        return null;
    }
    public static function DirToVector(dir:Dir):IntVector
    {
        switch(dir)
        {
            case Dir.Down:
                return {x: 0, y: 1};
            case Dir.Up:
                return {x: 0, y: -1};
            case Dir.Right:
                return {x: 1, y: 0};
            case Dir.Left:
                return {x: -1, y: 0};
        }
        
        return {x: 0, y: 0};
    }
    public static function DirToString(dir:Dir):String
    {
        switch(dir)
        {
            case Dir.Down:
                return 'down';
            case Dir.Up:
                return 'up';
            case Dir.Right:
                return 'right';
            case Dir.Left:
                return 'left';
        }
        
        return 'left';
    }

    public static function LoopIndex(index:Int, delta:Int, length:Int):Int
    {
        var nextIndex = index + delta;

        if(nextIndex < 0)
            return length - 1;

        if(nextIndex >= length)
            return 0;

        return nextIndex;
    }

    public static inline function Sign(value:Float)
    {
        if(value < 0)
            return -1;
        if(value > 0)
            return 1;
        return 0;
    }
    public static function RandomFloat(min:Float, max:Float)
    {
        return Math.random() * (max - min) + min;
    }
    public static function Random(min:Int, max:Int)
    {
        return Math.floor(Math.random() * (max - min + 1) + min);
    }
    public static function RandomArray<T>(array:Array<T>)
    {
        return array[Utils.Random(0, array.length - 1)];
    }

    public static inline function Clamp(value:Float, min:Float, max:Float)
    {
        return Math.min(Math.max(value, min), max);
    }

    public static inline function ToRadians(angle:Float):Float
    {
        return angle * (Math.PI / 180);
    }

    public static inline function RotateVector(vector:h3d.Vector, quat:h3d.Quat):h3d.Vector
    {
        var q = new h3d.Vector(quat.x, quat.y, quat.z);
        var t = 2 * vector.cross(q);
        var crossT = t.cross(q);
        return vector.add(quat.w * t + crossT);
    }

    public static function ReadableSide(side:Int):String
    {
        switch(side)
        {
            case 0:
                return 'низ';
            case 1:
                return 'лево';
            case 2:
                return 'перед';
            case 3:
                return 'право';
            case 4:
                return 'зад';
            case 5:
                return 'верх';
        }
        return 'куёлда';
    }

    public static function ShadeColor(color:Int, percent:Float):Int
    {
        var R = color >> 16;
        var G = color - (R << 16) >> 8;
        var B = color - (R << 16) - (G << 8);      
    
        R = Math.floor(R * percent);
        G = Math.floor(G * percent);
        B = Math.floor(B * percent);
    
        R = (R < 255) ? R : 255;
        G = (G < 255) ? G : 255;  
        B = (B < 255) ? B : 255;  
    
        R = Math.round(R);
        G = Math.round(G);
        B = Math.round(B);

        var newColor = R;
        newColor = (newColor << 8) + G;
        newColor = (newColor << 8) + B;

        return newColor;
    }
    
}
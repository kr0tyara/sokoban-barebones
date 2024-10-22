class Utils
{
    public static function LoopIndex(index:Int, delta:Int, length:Int):Int
    {
        var nextIndex = index + delta;

        if(nextIndex < 0)
            return length - 1;

        if(nextIndex >= length)
            return 0;

        return nextIndex;
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
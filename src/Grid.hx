import cdb.Types.ArrayRead;
import entities.objects.Player;
import haxe.Exception;
import entities.BaseEntity;
import avatars.*;
import entities.FloorEntity;
import entities.ObjectEntity;

class Grid
{
    public var stayWithinBounds:Bool = false;
    public var gravity:Bool = false;

    public var allEntities:Array<BaseEntity>;
    
    private var floors:Array<FloorEntity>;
    private var objects:Array<ObjectEntity>;

    public var width:Int;
    public var height:Int;

    private var levelData:Data.Levels;
    
    public function new(levelData:Data.Levels)
    {
        this.levelData = levelData;

        width = levelData.width;
        height = levelData.height;

        objects = new Array();
        floors  = new Array();
    }

    public function Init()
    {
        DecodeLevel();

        Game.history.Initialize(this);
        OnMovementEnd(true);
    }
    
    private function DecodeLevel()
    {
        allEntities = new Array<BaseEntity>();

        var objects = levelData.objects;
        for(obj in objects)
            SpawnObjectTile(obj.objectId, obj.x, obj.y, obj.tag, obj.customArguments.map(a -> a.argument));

        var floors = levelData.floor.decode(Data.floor.all);
        for(i in 0...floors.length)
        {
            var x = i % width;
            var y = Math.floor(i / width);
            
            SpawnFloorTile(floors[i].id, x, y);
        }
    }

    public function SortByDirection(list:Array<ObjectEntity>, dirX:Int, dirY:Int)
    {
        var list = list.copy();
            
        if(dirX == -1)
            list.sort((a, b) -> a.x - b.x);
        else if(dirX == 1)
            list.sort((a, b) -> b.x - a.x);
        else if(dirY == -1)
            list.sort((a, b) -> a.y - b.y);
        else if(dirY == 1)
            list.sort((a, b) -> b.y - a.y);

        return list;
    }

    // customArguments can be defined both in the Data.objects definition itself and for individual object instances at the level.
    // Custom arguments defined in the Data.objects go first, Data.Levels_objects go next.
    //  For example, entities.objects.Player has an optional argument altSprite.
    //  level02 that contains two Players with altSprite that is defined in two ways: as a separate object PlayerAltSprite and a Player with a customArgument.
    public function SpawnObjectTile(kind:Data.ObjectsKind, x:Int, y:Int, tag:String = '', customArguments:Array<Dynamic> = null)
    {
        if(kind == Data.ObjectsKind.Void)
            return null;

        var object = Data.objects.get(kind);
        var objectClass = Type.resolveClass('entities.objects.${object.className}');

        if(objectClass == null)
        {
            throw new Exception('No such class: entities.objects.${object.className}');
            return null;
        }

        var args:Array<Dynamic> = [kind];
        if(object.customArguments.length > 0)
            args = args.concat(object.customArguments.map(a -> a.argument));
        if(customArguments != null)
            args = args.concat(customArguments);

        var object = Type.createInstance(objectClass, args);
        object.tag = tag;

        return AddObject(object, x, y);
    }
    public function AddObject(object:ObjectEntity, x:Int, y:Int)
    {
        if(stayWithinBounds && (x < 0 || x >= width || y < 0 || y >= height))
        {
            throw new Exception('AddObject $object out of bounds: {$x, $y}');
            return null;
        }

        object.x = x;
        object.y = y;

        objects.push(object);
        allEntities.push(object);

        object.OnCreate();
        return object;
    }

    public function SpawnFloorTile(kind:Data.FloorKind, x:Int, y:Int, tag:String = '', customArguments:Array<Dynamic> = null)
    {
        if(kind == Data.FloorKind.Hole)
            return null;

        var floor = Data.floor.get(kind);
        var floorClass = Type.resolveClass('entities.floors.${floor.className}');

        if(floorClass == null)
        {
            throw new Exception('No such class: entities.floors.${floor.className}');
            return null;
        }

        var args:Array<Dynamic> = [kind];
        if(floor.customArguments.length > 0)
            args = args.concat(floor.customArguments.map(a -> a.argument));
        if(customArguments != null)
            args = args.concat(customArguments);

        var floor = Type.createInstance(floorClass, args);
        floor.tag = tag;

        return AddFloor(floor, x, y);
    }
    public function AddFloor(floor:FloorEntity, x:Int, y:Int)
    {
        if(stayWithinBounds && (x < 0 || x >= width || y < 0 || y >= height))
        {
            throw new Exception('AddFloor $floor out of bounds: {$x, $y}');
            return null;
        }

        floor.x = x;
        floor.y = y;

        floors.push(floor);
        allEntities.push(floor);

        floor.OnCreate();
        return floor;
    }

    public var lastMovedEntities:Array<ObjectEntity> = [];

    public function Push(object:ObjectEntity, dirX:Int, dirY:Int, isPlayerMove:Bool):Bool
    {
        if(dirX != 0 && dirY != 0)
        {
            throw new Exception('Push $object invalid: {$dirX, $dirY}');
            return false;
        }

        var toMove = new Array<ObjectEntity>();
        var primaryGroup = object.GetPushGroup();

        if(!DiscoverPush(object, dirX, dirY, toMove, isPlayerMove))
            return false;

        var ordered = SortByDirection(toMove, dirX, dirY);

        lastMovedEntities = [];
        for(entity in ordered)
            if(Move(entity, dirX, dirY, isPlayerMove && primaryGroup.contains(entity)))
                lastMovedEntities.push(entity);

        return true;
    }

    private function DiscoverPush(entity:ObjectEntity, dirX:Int, dirY:Int, toMove:Array<ObjectEntity>, isPlayerMove:Bool):Bool
    {
        if(toMove.contains(entity))
            return true;

        var group = entity.GetPushGroup();

        for(member in group)
        {
            if(stayWithinBounds && (member.x + dirX < 0 || member.x + dirX >= width || member.y + dirY < 0 || member.y + dirY >= height))
                return false;

            if(!member.CanPush(dirX, dirY, isPlayerMove))
                return false;

            var floor = GetFloor(member.x + dirX, member.y + dirY);
            if((!gravity && floor == null) || (floor != null && !floor.CanStepOn(member)))
                return false;
        }

        for(member in group)
            if(!toMove.contains(member))
                toMove.push(member);

        for(member in group)
        {
            var occupant = GetObject(member.x + dirX, member.y + dirY);

            if(occupant == null || group.contains(occupant) || toMove.contains(occupant))
                continue;

            if(!DiscoverPush(occupant, dirX, dirY, toMove, isPlayerMove))
            {
                for(m in group)
                    toMove.remove(m);
                
                return false;
            }
        }

        return true;
    }
    
    public function Destroy(entity:BaseEntity, notify:Bool = true)
    {
        if(notify)
            Game.history.NotifyDestroyed(entity);

        entity.OnDestroy();
        allEntities.remove(entity);

        if(entity is ObjectEntity)
            objects.remove(cast entity);

        else if(entity is FloorEntity)
            floors.remove(cast entity);
    }

    public function Revive(entity:BaseEntity)
    {
        allEntities.push(entity);

        if(entity is ObjectEntity)
            objects.push(cast entity);

        else if(entity is FloorEntity)
            floors.push(cast entity);

        entity.OnCreate();
    }

    public function Move(object:ObjectEntity, dirX:Int, dirY:Int, isPlayerMove:Bool):Bool
    {
        if(dirX != 0 && dirY != 0)
        {
            throw new Exception('Move invalid: {$dirX, $dirY}');
            return false;
        }
        
        if(stayWithinBounds && (object.x + dirX < 0 || object.x + dirX >= width || object.y + dirY < 0 || object.y + dirY >= height))
        {
            throw new Exception('Move out of bounds: {${object.x} + $dirX, ${object.y} + $dirY');
            return false;
        }

        var toX = object.x + dirX;
        var toY = object.y + dirY;

        var floor = GetFloor(toX, toY);
        
        if(!gravity && floor == null)
        {
            trace('WARNING: can\'t move to [$toX, $toY]: no floor!');
            return false;
        }

        if(floor != null && !floor.CanStepOn(object))
            return false;
        
        if(GetObject(toX, toY) != null)
        {
            trace('WARNING: can\'t move to [$toX, $toY]: it\'s occupied!');
            return false;
        }

        var oldX = object.x;
        var oldY = object.y;

        object.x = toX;
        object.y = toY;

        object.OnMove(dirX, dirY);

        if(floor != null)
            floor.StashStepOn(object);

        var oldFloor = GetFloor(oldX, oldY);
        if(oldFloor != null)
            oldFloor.StashStepOff(object);

        return true;
    }

    public function OnMovementEnd(initial:Bool)
    {
        var activeEntities = allEntities.filter(a -> a.active);

        for(entity in activeEntities)
            entity.OnPreTick(initial);

        for(entity in activeEntities)
            entity.OnTick(initial);

        var objects = GetAllObjects();
        var object = Utils.Find(objects, NeedsToDie);
        while(object != null)
        {
            object.Deactivate();
            object = Utils.Find(objects, NeedsToDie);
        }

        objects = GetAllObjects();
        for(object in objects)
        {
            var floor = GetFloor(object.x, object.y);
            if(floor is entities.floors.Mover)
            {
                var mover = cast(floor, entities.floors.Mover);
                Push(object, mover.direction.x, mover.direction.y, false);
            }
        }

        for(entity in activeEntities)
            entity.OnPostTick(initial);
        
        Game.history.MakeState();
        CheckLevelCompletion();
    }
    public function NeedsToDie(a:ObjectEntity)
    {
        return !a.invisible && a.active && GetFloor(a.x, a.y) == null && a.GetPushGroup().filter(a -> GetFloor(a.x, a.y) != null).length == 0;
    }

    private var completionQueued:Bool = false;
    public function AnyPlayerMoving():Bool
    {
        for(player in GetPlayers())
        {
            var avatar = cast(player.avatar, ObjectAvatar);
            if(avatar != null && avatar.isMoving)
                return true;
        }

        return false;
    }

    public function CheckLevelCompletion()
    {
        var won = true;

        var goals = floors.filter(a -> a is entities.floors.Goal);

        if(goals.length == 0)
            return;

        // to win, there should be a block on top of each goal 
        for(goal in goals)
        {
            var object = GetObject(goal.x, goal.y);
            if(object == null || !(object is entities.objects.Block))
            {
                won = false;
                break;
            }
        }

        if(won && !completionQueued)
        {
            completionQueued = true;
            ActionQueue.inst.WaitUntil(() -> !AnyPlayerMoving(), () -> Game.level.OnComplete());
        }
    }

    public function GetPlayers()
    {
        return GetAllObjects().filter(a -> a is Player).map(a -> cast(a, Player));
    }

    public function GetAllObjects(onlyActive:Bool = true)
    {
        return objects.filter(a -> onlyActive ? a.active : true);
    }
    public function GetObjects(x:Int, y:Int):Array<ObjectEntity>
    {
        if(stayWithinBounds && (x < 0 || x >= width || y < 0 || y >= height))
            return [];

        return objects.filter(a -> a.active && a.x == x && a.y == y && !a.invisible);
    }
    public function GetObject(x:Int, y:Int):ObjectEntity
    {
        var objects = GetObjects(x, y);
        if(objects.length == 0)
            return null;

        // here you can filter for certain object types you're looking for. 
        // this example code just grabs the first object under the specified coordinates, which is
        // not perfect if you want to use multiple objects per same tile
        // (like sugar cubes or rat carriers from desperatea)
        
        return objects[0];
    }
    public function GetObjectByTag(tag:String):ObjectEntity
    {
        var objects = objects.filter(a -> a.tag == tag);
        if(objects.length == 0)
            return null;
        
        return objects[0];
    }

    public function GetAllFloors(onlyActive:Bool = true)
    {
        return floors.filter(a -> onlyActive ? a.active : true);
    }
    public function GetFloor(x:Int, y:Int):FloorEntity
    {
        if(stayWithinBounds && (x < 0 || x >= width || y < 0 || y >= height))
            return null;

        return GetAllFloors().filter(a -> a.x == x && a.y == y)[0];
    }
    public function GetFloorByTag(tag:String):FloorEntity
    {
        var floor = floors.filter(a -> a.tag == tag);
        if(floor.length == 0)
            return null;
        
        return floor[0];
    }
}
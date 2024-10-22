import entities.Wall;
import entities.Player;
import entities.Block;
import entities.Entity;
import entities.BaseEntity;
import haxe.Exception;
import haxe.ds.Vector;
import entities.objects.*;
import entities.floors.*;

typedef Neighbour = {
    entity:Entity,
    side:Int
};

typedef FallResult = {
    floor:BaseEntity,
    z:Int
};

class Grid
{
    private var entities:Vector<Vector<Vector<Entity>>>;

    public var width:Int;
    public var length:Int;
    public var height:Int;

    public var players:Array<Player>;
    public var allEntities:Array<BaseEntity>;

    private var levelData:Data.Levels;
    
    public function new(levelData:Data.Levels)
    {
        this.levelData = levelData;

        width = levelData.width;
        length = levelData.height;
        height = 1;

        entities = new Vector(height);
        for(i in 0...height)
        {
            entities[i] = new Vector(length);

            for(j in 0...length)
            {
                entities[i][j] = new Vector(width, null);
            }
        }
        
        DecodeLevel();
    }
    
    private function DecodeLevel()
    {
        players = new Array<Player>();
        allEntities = new Array<BaseEntity>();

        var entities = levelData.entities.decode(Data.entities.all);

        for(i in 0...entities.length)
        {
            var x = i % width;
            var y = Math.floor(i / width);
            SpawnTile(entities[i].id, x, y, 0);
        }

        Game.history.Initialize(this);
        Game.history.MakeState();
    }

    public function SortByDirection(dirX:Int, dirY:Int)
    {
        var list = players.copy();
            
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

    public function SpawnTile(kind:Data.EntitiesKind, x:Int, y:Int, z:Int)
    {
        var entity:Entity;
        switch(kind)
        {
            case Data.EntitiesKind.Player:
                entity = new Player();
                players.push(cast(entity, Player));

            case Data.EntitiesKind.Block:
                entity = new Block();

            case Data.EntitiesKind.Wall:
                entity = new Wall();

            default:
                entity = null;
        }

        if(entity != null)
        {
            AddEntity(entity, x, y, z);
        }
    }

    public function AddEntity(entity:Entity, x:Int, y:Int, z:Int)
    {
        if(x < 0 || x >= width || y < 0 || y >= length || z < 0 || z >= height)
        {
            throw Exception;
            return;
        }

        entities[z][y][x] = entity;
        entity.x = x;
        entity.y = y;
        entity.z = z;
        entity.OnCreate();

        allEntities.push(entity);
    }

    public function Push(fromX:Int, fromY:Int, fromZ:Int, dirX:Int, dirY:Int, dirZ:Int):Bool
    {
        if(dirX != 0 && dirY != 0 && dirZ != 0)
        {
            throw Exception;
            return false;
        }

        if(fromX < 0 || fromX >= width || fromY < 0 || fromY >= length || fromZ < 0 || fromZ >= height)
        {
            throw Exception;
            return false;
        }

        var entity = entities[fromZ][fromY][fromX];
        if(entity == null)
        {
            trace('WARNING: nothing to push from [$fromX, $fromY]');
            return true;
        }

        if(fromX + dirX < 0 || fromX + dirX >= width || fromY + dirY < 0 || fromY + dirY >= length || fromZ + dirZ < 0 || fromZ + dirZ >= height)
        {
            return false;
        }

        if(!entity.CanPush(dirX, dirY, dirZ))
        {
            return false;
        }

        var entityOnwards = entities[fromZ + dirZ][fromY + dirY][fromX + dirX];
        if(entityOnwards == null)
        {
            return Move(fromX, fromY, fromZ, dirX, dirY, dirZ);
        }
        else
        {
            if(Push(fromX + dirX, fromY + dirY, fromZ, dirX, dirY, dirZ))
            {
                entityOnwards.pushedThisFrame = true;
                return Move(fromX, fromY, fromZ, dirX, dirY, dirZ);
            }
        }

        return false;
    }

    public function Destroy(x:Int, y:Int, z:Int)
    {
        if(x < 0 || x >= width || y < 0 || y >= length || z < 0 || z >= height)
        {
            throw Exception;
        }

        if(entities[z][y][x] != null)
        {
            entities[z][y][x].OnDestroy();
            allEntities.remove(entities[z][y][x]);
        }

        entities[z][y][x] = null;
    }

    public function RebuildGrid()
    {
        entities = new Vector(height);
        for(i in 0...height)
        {
            entities[i] = new Vector(length);

            for(j in 0...length)
            {
                entities[i][j] = new Vector(width, null);
            }
        }

        for(entity in allEntities)
        {
            /*if(entity is Floor)
                floors[entity.z][entity.y][entity.x] = cast(entity, Floor);
            else if(entity is Entity)*/
            entities[entity.z][entity.y][entity.x] = cast(entity, Entity);
        }
    }

    public function Move(fromX:Int, fromY:Int, fromZ:Int, dirX:Int, dirY:Int, dirZ:Int):Bool
    {
        if(dirX != 0 && dirY != 0 && dirZ != 0)
        {
            throw Exception;
            return false;
        }
        
        if(fromX < 0 || fromX >= width || fromY < 0 || fromY >= length || fromZ < 0 || fromZ >= height)
        {
            throw Exception;
            return false;
        }

        if(fromX + dirX < 0 || fromX + dirX >= width || fromY + dirY < 0 || fromY + dirY >= length || fromZ + dirZ < 0 || fromZ + dirZ >= height)
        {
            throw Exception;
            return false;
        }

        var toX = fromX + dirX;
        var toY = fromY + dirY;
        var toZ = fromZ + dirZ;

        var entity = entities[fromZ][fromY][fromX];
        if(entity == null)
        {
            trace('WARNING: nothing to move from [$fromX, $fromY, $fromZ]');
            return false;
        }

        //var floor:BaseEntity = GetFloor(toX, toY, toZ);

        // gravity
        /*var fall = FallZ(toX, toY, toZ);
        if(fall.floor != null)
        {
            floor = fall.floor;
            toZ = fall.z;
        }
        
        if(floor == null)
        {
            trace('WARNING: can\'t move to [$toX, $toY, $toZ]: no floor!');
            return false;
        }

        if(!floor.CanStep(entity))
            return false;*/
        
        if(entities[toZ][toY][toX] != null)
        {
            trace('WARNING: can\'t move to [$toX, $toY, $toZ]: it\'s occupied!');
            return false;
        }

        entities[fromZ][fromY][fromX] = null;
        entities[toZ][toY][toX] = entity;
        entity.x = toX;
        entity.y = toY;
        entity.z = toZ;
        entity.movedThisFrame = true;

        entity.OnMove(dirX, dirY, dirZ);
        //floor.OnStepOn(entity);

        // move neighbour on top
        /*var neighbours = GetNeighbourEntities(fromX, fromY, fromZ);
        for(neighbour in neighbours)
        {
            if(neighbour.side == BaseEntity.SIDE_UP)
            {
                Move(neighbour.entity.x, neighbour.entity.y, neighbour.entity.z, dirX, dirY, dirZ);
            }
        }*/

        /*var oldFloor = GetFloor(fromX, fromY, fromZ);
        if(oldFloor != null)
            oldFloor.OnStepOff(entity);*/

        return true;
    }

    public function OnMovementEnd(madeAnything:Bool)
    {
        for(z in 0...height)
        {
            for(y in 0...length)
            {
                for(x in 0...width)
                {
                    var entity = GetEntity(x, y, z);
                    if(entity == null)
                        continue;
                    
                    entity.movedThisFrame = false;
                    entity.pushedThisFrame = false;
                }
            }
        }

        Game.history.MakeState();
        CheckLevelCompletion();
    }

    public function GetNeighbourEntities(x:Int, y:Int, z:Int):Array<Neighbour>
    {
        if(x < 0 || x >= width || y < 0 || y >= length || z < 0 || z >= height)
        {
            throw Exception;
            return [];
        }

        var positions = [{x: x - 1, y: y, z: z, side: BaseEntity.SIDE_LEFT}, {x: x + 1, y: y, z: z, side: BaseEntity.SIDE_RIGHT}, {x: x, y: y + 1, z: z, side: BaseEntity.SIDE_FRONT}, {x: x, y: y - 1, z: z, side: BaseEntity.SIDE_BACK}, {x: x, y: y, z: z + 1, side: BaseEntity.SIDE_UP}, {x: x, y: y, z: z - 1, side: BaseEntity.SIDE_BOTTOM}];
        var neighbours = new Array<Neighbour>();
        
        for(position in positions)
        {
            if(position.x < 0 || position.x >= width || position.y < 0 || position.y >= length || position.z < 0 || position.z >= height)
                continue;

            var neighbour = GetEntity(position.x, position.y, position.z);
            if(neighbour != null)
                neighbours.push({entity: neighbour, side: position.side});
        }

        return neighbours;
    }

    public function CheckLevelCompletion()
    {
        trace('todo');
        /*
        var failed = false;

        for(z in 0...height)
        {
            for(y in 0...length)
            {
                for(x in 0...width)
                {
                    var floor = GetFloor(x, y, z);
                    if(floor != null && floor is GoalFloor && !floor.CanDropInk(BaseEntity.SIDE_UP))
                    {
                        failed = true;
                    }
                }
            }
        }

        if(!failed)
        {
            Game.level.Complete();
        }*/
    }

    public function GetEntity(x:Int, y:Int, z:Int):Entity
    {
        if(x < 0 || x >= width || y < 0 || y >= length || z < 0 || z >= height)
        {
            throw Exception;
            return null;
        }

        return entities[z][y][x];
    }
}
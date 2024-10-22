package avatars;

import entities.Entity;
import h3d.scene.Mesh;

class PlayerAvatar extends Avatar
{
    private var faceMesh:Mesh;
    
    public function new(prototype:Entity)
    {
        super(prototype);
    }
}
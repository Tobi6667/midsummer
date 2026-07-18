using UnityEngine;

public class SpawnCharacterEvent : IGameEvent
{
    public EnemyBase Character;
    public Vector3 SpawnPosition;
}

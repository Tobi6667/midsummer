using UnityEngine;

public class SpawnItemEvent : IGameEvent
{
    public PickUpBase Item;
    public Vector3 SpawnPosition;
}

using System;
using UnityEngine;

public class SpawnManager : MonoBehaviour
{

    // Start is called once before the first execution of Update after the MonoBehaviour is created

    private void Awake()
    {

    }

    private void Start()
    {
        StoryEventBus.Subscribe<GuardTalkedEvent>(SpawnCharacter);
        StoryEventBus.Subscribe<SpawnItemEvent>(SpawnItem);
    }

    private void SpawnCharacter(GuardTalkedEvent @event)
    {
        var e = Instantiate(@event.spawnCharacter, @event.spawnPos, Quaternion.identity);
        e.Initialize();
    }

private void SpawnItem(SpawnItemEvent @event)
{
    var ite = Instantiate(@event.Item, @event.SpawnPosition, Quaternion.identity);

}


    private void OnDisable()
    {
        StoryEventBus.Unsubscribe<GuardTalkedEvent>(SpawnCharacter);
    }


}

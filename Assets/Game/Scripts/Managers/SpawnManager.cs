using System;
using System.Collections.Generic;
using UnityEngine;

public class SpawnManager : MonoBehaviour
{

    [SerializeField] private List<ItemSaveData> _saveItemList;

    // Start is called once before the first execution of Update after the MonoBehaviour is created

    private void Awake()
    {

    }

    private void Start()
    {
        StoryEventBus.Subscribe<GuardTalkedEvent>(SpawnCharacter);
        StoryEventBus.Subscribe<SpawnItemEvent>(SpawnItem);
        StoryEventBus.Subscribe<SpawnCharacterEvent>(RespawnItems);
        StoryEventBus.Subscribe<TrapPickupEvent>(SafeTrapData);

/*
        foreach (var item in _itemsList)
        {
            var it = new ItemSaveData();
            it.Item = item.GetItem();
            it.SpwanPosition = item.transform;
            _saveItemList.Add(it);
        }
*/
    }

    private void SafeTrapData(TrapPickupEvent @event)
    {

        var it = new ItemSaveData();
        it.Item = @event.TrapPickup.GetItem();
        it.SpawnPosition = @event.TrapPickup.gameObject.transform.position;
        it.SpawnRotation = @event.TrapPickup.gameObject.transform.rotation;


        _saveItemList.Add(it);
    }

    private void RespawnItems(SpawnCharacterEvent @event)
    {
        foreach(var ite in _saveItemList)
        {
            var trap = Instantiate(ite.Item.worldPrefab, ite.SpawnPosition, ite.SpawnRotation);
        }
        _saveItemList.Clear();

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
        StoryEventBus.Unsubscribe<SpawnItemEvent>(SpawnItem);
        StoryEventBus.Unsubscribe<SpawnCharacterEvent>(RespawnItems);
        StoryEventBus.Unsubscribe<TrapPickupEvent>(SafeTrapData);
    }


}

using System.Collections.Generic;
using UnityEngine;

public class InventoryManagerNEW : MonoBehaviour
{
    public static InventoryManagerNEW Instance;

    [SerializeField] private List<InventorySlotData> _inventorySlots;
    private HashSet<SoInventoryItem> _abilityItems;

    private void Awake()
    {
        Instance = this;
        if (_inventorySlots == null)
            _inventorySlots = new List<InventorySlotData>();
        _abilityItems = new HashSet<SoInventoryItem>();
    }

    public bool HasItem(SoInventoryItem _item)
    {
        if (_abilityItems.Contains(_item))
            return true;

        foreach (InventorySlotData item in _inventorySlots)
        {
            if (item.item == _item)
                return true;
        }
        return false;
    }

    public void DropItem(int index, Transform dropPosition)
    {
        if (index < 0 || index >= _inventorySlots.Count)
            return;

        InventorySlotData slot = _inventorySlots[index];

        Instantiate(
            slot.item.worldPrefab,
            dropPosition.position,
            Quaternion.identity
        );

        slot.amount--;

        if (slot.amount <= 0)
        {
            _inventorySlots.RemoveAt(index);
            UIManager.Instance.RefreshInventory(_inventorySlots);
        }
        else
        {
            UIManager.Instance.UpdateInventorySlot(index, slot);
        }
    }

    public void AddItem(SoInventoryItem item)
    {
        if (item.isAbility)
        {
            _abilityItems.Add(item);
            return; // no slot, no UI call
        }

        // check if item already exists
        foreach (InventorySlotData slot in _inventorySlots)
        {
            if (slot.item == item)
            {
                slot.amount++;

                UIManager.Instance.UpdateInventorySlot(
                    _inventorySlots.IndexOf(slot),
                    slot
                );

                return;
            }
        }

        // otherwise create new slot
        InventorySlotData newSlot = new InventorySlotData(item, 1);

        _inventorySlots.Add(newSlot);

        int index = _inventorySlots.Count - 1;

        UIManager.Instance.AddInventoryItem(newSlot, index);
    }
}
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.InputSystem;
using UnityEngine.UIElements;

public class InventoryManagerNEW : MonoBehaviour
{
    public static InventoryManagerNEW Instance;

    [SerializeField] private List<SoInventoryItem> _inventoryItems;

    private void Awake()
    {
        Instance = this;
    }

    // Start is called once before the first execution of Update after the MonoBehaviour is created
    void Start()
    {
        foreach (SoInventoryItem item in _inventoryItems)
        {
            UIManager.Instance.AddInventoryItem(item, (selectedItem) => {
                DragItem(selectedItem);
            });
        }
    }


    public bool HasItem(SoInventoryItem _item)
    {
        foreach(SoInventoryItem item in _inventoryItems)
        {

            if (item == _item)
            {
                return true;
            }


        }
        return false;
    }

    internal void DragItem(SoInventoryItem item)
    {
        
        var instantiatedItem = Instantiate(item.worldPrefab, GameManager.Instance.PlayerController.transform.position, Quaternion.identity);
    }
}

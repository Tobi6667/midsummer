using System.Collections.Generic;
using UnityEngine;
using UnityEngine.InputSystem;
using UnityEngine.UIElements;

public class InventoryManagerNEW : MonoBehaviour
{


    [SerializeField] private List<SoInventoryItem> _inventoryItems;

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

    internal void DragItem(SoInventoryItem item)
    {
        
        var instantiatedItem = Instantiate(item.worldPrefab, GameManager.Instance.PlayerController.transform.position, Quaternion.identity);
    }
}

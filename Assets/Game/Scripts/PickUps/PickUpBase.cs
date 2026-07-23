using UnityEngine;
using UnityEngine.InputSystem;

public abstract class PickUpBase : MonoBehaviour        
{
    [SerializeField] private SoInventoryItem InventoryItem;

    public SoInventoryItem GetItem()
    {
        return InventoryItem;
    }

    

}

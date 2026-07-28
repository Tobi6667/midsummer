using UnityEngine;
using UnityEngine.InputSystem;

public abstract class PickUpBase : MonoBehaviour        
{
    [SerializeField] private SoInventoryItem InventoryItem;
    internal bool isTriggered = false;
    public SoInventoryItem GetItem()
    {
        return InventoryItem;
    }

    public bool IsTriggered()
    {
        return isTriggered;
    }

    public void SetTriggered()
    {
        isTriggered = true;
    }

}

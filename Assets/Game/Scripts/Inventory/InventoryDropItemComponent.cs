using UnityEngine;

public class InventoryDropItemComponent : MonoBehaviour
{
    internal void DragItem(SoInventoryItem item)
    {
        
        var instantiatedItem = Instantiate(item.worldPrefab, transform.position, Quaternion.identity);
    }
}

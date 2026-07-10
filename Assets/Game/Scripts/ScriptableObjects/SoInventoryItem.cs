using UnityEngine;

[CreateAssetMenu(menuName = "Inventory/Item")]
public class SoInventoryItem : ScriptableObject
{
    public string itemName;
    public Sprite icon;
    public int maxStack = 99;
    public PickUpBase worldPrefab;
}
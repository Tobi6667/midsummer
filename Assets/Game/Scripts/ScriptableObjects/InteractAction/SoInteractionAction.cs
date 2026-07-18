using UnityEngine;


[CreateAssetMenu(menuName = "Interaction Action")]
public class SoInteractionAction : ScriptableObject
{
    public string actionName;
    public SoInventoryItem inventoryItem;
    public bool needsItem;
    public EInteractionType interactionType;
}

using UnityEngine;

[CreateAssetMenu(menuName = "Interaction Action")]
public class SoInteractionAction : ScriptableObject
{
    public string actionName;
    public SoInventoryItem inventoryItem;
    public bool needsItem;
    public EInteractionType interactionType;
    public AnimationClip[] animationClips; // the branch tail — "do A" vs "do B"
    public AnimationClip loopClip;         // optional, passed through to PlayAnimations
}
using System.Collections.Generic;
using UnityEngine;

[CreateAssetMenu(fileName = "InteractionPoint", menuName = "Dream/Interaction Point")]
public class SoInteractionPoint : ScriptableObject
{
    public List<AnimationClip> _animationClips;
}

using System.Collections.Generic;
using UnityEngine;

public class InteractionPoint : MonoBehaviour
{
    public SoInteractionPoint _interactionData;
    public Transform _interactPosition;
    //public AnimationClip[] animationSequence;
    public bool _isOccupied {  get; private set; }

    public void SetOccupied(bool occupied)
    {
        _isOccupied = occupied;
    }

    public bool IsOccupied { get { return _isOccupied; } }

    public AnimationClip[] animationSequence
    {
        get
        {
            if (_interactionData != null)
            {
                return _interactionData._animationClips.ToArray();
            }
            else
            {
                Debug.LogWarning("Interaction data is not assigned for " + gameObject.name);
                return new AnimationClip[0];
            }
        }
    }
}

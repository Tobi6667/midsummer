using Unity.VisualScripting;
using UnityEngine;

public abstract class InteractActionBase : MonoBehaviour, IInteractable
{

    [SerializeField] protected Transform _interactPoint;
    [SerializeField] protected AnimationClip[] _transitionClip;
    [SerializeField] protected AnimationClip _loopClip;


    public Transform InteractionPoint => _interactPoint;
    public AnimationClip LoopClip => _loopClip;

    public AnimationClip[] TransitionClip => _transitionClip;

    public void Interact()
    {
        Debug.Log("interaction act");
    }


}

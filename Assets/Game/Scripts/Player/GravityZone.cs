using UnityEngine;

// Place on a trigger collider. Defines "up" for anything inside as this
// object's own transform.up. Player transitions gravity only when entering/
// exiting one of these — no continuous surface probing, no corner-case
// normal chasing. Overlapping zones use whichever was entered most recently.
[RequireComponent(typeof(Collider))]
public class GravityZone : MonoBehaviour
{
    [Tooltip("How long the player takes to rotate into this zone's gravity when entering.")]
    public float transitionDuration = 0.4f;

    void Reset()
    {
        GetComponent<Collider>().isTrigger = true;
    }

    void OnTriggerEnter(Collider other)
    {
        Debug.Log("Player entered gravity zone: " + name);
        var receiver = other.GetComponentInParent<PlayerGravityReceiver>();
        if (receiver != null)
            receiver.EnterZone(this);
    }

    void OnTriggerExit(Collider other)
    {
        var receiver = other.GetComponentInParent<PlayerGravityReceiver>();
        if (receiver != null)
            receiver.ExitZone(this);
    }

    public Vector3 Up => transform.up;
}
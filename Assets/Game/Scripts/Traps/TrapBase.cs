using UnityEngine;

public abstract class TrapBase : MonoBehaviour
{
    public bool _isActive = false;
    public virtual void TriggerTrap()
    {

        if (!_isActive) return;

        // Default implementation for activating the trap
        Debug.Log("Trap activated!");
    }

    //public virtual ActivateTrap()

}

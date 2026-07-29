using System;
using UnityEngine;

public class StatueInteractor :MonoBehaviour,  IInteractable
{
    [SerializeField] private TrapItemBase _trapitem;
    [SerializeField] private Transform _dropPoint;
    private bool didDrop = false;
    public void Interact(Action onFinished)
    {
        if(!didDrop)
        {
            Instantiate(_trapitem, _dropPoint.position, Quaternion.identity);
            didDrop = true;
        }

    }

}

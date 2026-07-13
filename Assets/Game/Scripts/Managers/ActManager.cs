using NUnit.Framework;
using System.Collections.Generic;
using UnityEngine;

public  class ActManager : MonoBehaviour
{
    public static ActManager Instance;

    [SerializeField] private List<ActorController> _actors;

    private void Awake()
    {
        Instance = this;
    }

    public void PlayAct()
    {
        foreach (var actor in _actors)
        {
            actor.StartActing();
        }
    }



}

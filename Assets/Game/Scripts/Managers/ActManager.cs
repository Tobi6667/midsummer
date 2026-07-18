using NUnit.Framework;
using System.Collections.Generic;
using UnityEngine;

public  class ActManager : MonoBehaviour
{
    public static ActManager Instance;

    [SerializeField] private ActPlayData _actData;

    private void Awake()
    {
        Instance = this;
    }

    public void PlayAct()
    {
        Debug.Log("start actor");
        foreach (var actor in _actData._actors)
        {
            actor.StartActing();
        }
    }

    public void StopAct()
    {

        Debug.Log("STOP THE SHIT");
        foreach(var actor in _actData._actors)
        {
            actor.StopAct();
        }
    }



}

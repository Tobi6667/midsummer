using System;
using UnityEngine;

public class WallOne : BlockPathBase
{

    private void Start()
    {
        StoryEventBus.Subscribe<FinishTutorialEvent>(OnTutorialDone);
    }

    private void OnTutorialDone(FinishTutorialEvent @event)
    {
        Debug.Log("tutorial DOOONE");
        OpenPath();
    }

    internal void OpenDoor()
    {
        OpenPath();
    }

    private void OnDisable()
    {
        StoryEventBus.Unsubscribe<FinishTutorialEvent>(OnTutorialDone);

    }
}

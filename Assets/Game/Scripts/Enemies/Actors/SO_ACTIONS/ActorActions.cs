using UnityEngine;

[System.Serializable]
public class ActorActions
{
    public EActorAction action;
    public Transform target;
    public AnimationClip[] animation;
    public AudioClip voice;
    public bool sendEvent;
    public float waitTime;
}
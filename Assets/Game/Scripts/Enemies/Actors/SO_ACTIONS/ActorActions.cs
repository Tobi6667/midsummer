using UnityEngine;
using UnityEngine.Playables;

[System.Serializable]
public class ActorActions
{
    public EActorAction action;
    public Transform target;
    public AnimationClip[] animation;
    public AudioClip voice;
    public bool sendEvent;
    public float waitTime;
    public bool needsItem;
    public bool removeCurtain;
    public PlayableDirector timeline;
}
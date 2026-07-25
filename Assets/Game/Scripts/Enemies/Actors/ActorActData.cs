using UnityEngine;

[System.Serializable]
public class ActorActData
{
    public EActorAction action;

    // Move
    public Transform target;

    // Animation
    public string animationName;

    // Dialogue
    [TextArea]
    public string text;
    public AudioClip voice;

    // Wait
    public float waitTime;
}
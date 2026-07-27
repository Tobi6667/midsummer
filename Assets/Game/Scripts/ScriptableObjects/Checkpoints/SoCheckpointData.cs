using UnityEngine;

[CreateAssetMenu(menuName = "Chechkpoint")]
public class SoCheckpointData : ScriptableObject
{
    [TextArea]
    public string taskDescription;
    public AudioClip areaAudio;

}

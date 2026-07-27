using UnityEngine;

public class PlayerBase : MonoBehaviour
{
    public float DetectionValue;
    public Checkpoint CurrentCheckpoint;

    public virtual void UpdateStats(float _val)
    {
        DetectionValue -= _val;
        if(DetectionValue<=0)
        {
            ResetToCheckpoint();
            DetectionValue = 80;

        }
        UIManager.Instance.UpdateDetectionBar(DetectionValue);
    }



    private void ResetToCheckpoint()
    {
        transform.position = CurrentCheckpoint.SpawnPoint.position;
        StoryEventBus.Publish(new SpawnCharacterEvent());
    }

    private void OnTriggerEnter(Collider other)
    {
        if(other.TryGetComponent<Checkpoint>(out var check))
        {
            if (check != CurrentCheckpoint)
            {
                Debug.Log("checkpoint");

                CurrentCheckpoint = check;
                AudioManager.Instance.PlayMusic(check.CheckpointData.areaAudio);
                
            }
        }
    }

}

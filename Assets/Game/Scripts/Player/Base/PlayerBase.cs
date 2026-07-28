using UnityEngine;

public class PlayerBase : MonoBehaviour
{
    public float DetectionValue;
    public Checkpoint CurrentCheckpoint;
    [SerializeField] private AudioSource HitAudio;

    private PlayerGravityReceiver _baseGravityReceiver;

    protected virtual void Awake()
    {
        _baseGravityReceiver = GetComponent<PlayerGravityReceiver>();
    }

    public virtual void UpdateStats(float _val)
    {
        Debug.Log("hit "+_val);
        HitAudio.Play();
        DetectionValue -= _val;
        if (DetectionValue <= 0)
        {
            DetectionValue = 80;
            ResetToCheckpoint();
        }
        UIManager.Instance.UpdateDetectionBar(DetectionValue);
    }

    private void ResetToCheckpoint()
    {
        Debug.Log("wtf to checkpoint" + CurrentCheckpoint.SpawnPoint);
        if (_baseGravityReceiver != null)
            _baseGravityReceiver.Teleport(CurrentCheckpoint.SpawnPoint.position);
        else
            transform.position = CurrentCheckpoint.SpawnPoint.position;
        StoryEventBus.Publish(new SpawnCharacterEvent());
    }

    private void OnTriggerEnter(Collider other)
    {
        if (other.TryGetComponent<Checkpoint>(out var check))
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
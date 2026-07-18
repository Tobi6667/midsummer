using UnityEngine;

public class PlayerBase : MonoBehaviour
{
    public float DetectionValue;
    public Transform CurrentCheckpoint;

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

    public virtual void SetCheckpoint(Transform checkP)
    {
        CurrentCheckpoint = checkP;
    }

    private void ResetToCheckpoint()
    {
        transform.position = CurrentCheckpoint.position;
    }

    private void OnTriggerEnter(Collider other)
    {
        if(other.TryGetComponent<Checkpoint>(out var check))
        {
            Debug.Log("checkpoint");
            CurrentCheckpoint = check.spawnPoint;
        }
    }

}

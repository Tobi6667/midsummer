using UnityEngine;

public class Checkpoint : MonoBehaviour
{
    [SerializeField] private Transform _spawnPoint;
    [SerializeField] private SoCheckpointData _checkpointData;

    public Transform SpawnPoint => _spawnPoint;
    public SoCheckpointData CheckpointData => _checkpointData;
}

using UnityEngine;

public class Checkpoint : MonoBehaviour
{
    [SerializeField] private Transform _spawnPoint;

    public Transform spawnPoint => _spawnPoint;
}

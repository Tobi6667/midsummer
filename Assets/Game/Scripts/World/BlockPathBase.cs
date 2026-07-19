using UnityEngine;

public abstract class BlockPathBase : MonoBehaviour
{
    [SerializeField] private GameObject _wall;
    internal virtual void OpenPath()
    {
        _wall.SetActive(false);
    }
}

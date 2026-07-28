using UnityEngine;
using DG.Tweening;

public class ArrowProjectile : MonoBehaviour
{
    [SerializeField] private float _flightDuration = 0.6f;
    [SerializeField] private float _arcHeight = 2f;

    public void Launch(Vector3 targetPosition, System.Action onHit = null)
    {
        Vector3 start = transform.position;
        Vector3 mid = Vector3.Lerp(start, targetPosition, 0.5f) + Vector3.up * _arcHeight;

        Vector3[] path = { mid, targetPosition };

        transform.DOPath(path, _flightDuration, PathType.CatmullRom)
            .SetEase(Ease.Linear)
            .SetLookAt(0.02f, Vector3.up)
            .OnComplete(() =>
            {
                onHit?.Invoke();
                Destroy(gameObject);
            });
    }
}
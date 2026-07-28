using System.Collections.Generic;
using UnityEngine;

public class PlayerInteractionDetector : MonoBehaviour
{
    [SerializeField] private float _range = 2.5f;
    [SerializeField] private LayerMask _interactableMask;
    [SerializeField] private float _checkInterval = 0.1f;

    private readonly HashSet<IHighlight> _current = new();
    private readonly Collider[] _hits = new Collider[16];
    private float _timer;

    private void Update()
    {
        _timer -= Time.deltaTime;
        if (_timer > 0f) return;
        _timer = _checkInterval;

        int count = Physics.OverlapSphereNonAlloc(transform.position, _range, _hits, _interactableMask);
        var found = new HashSet<IHighlight>();

        for (int i = 0; i < count; i++)
        {
            if (_hits[i].TryGetComponent<IHighlight>(out var interactable))
                Debug.Log(interactable);
                found.Add(interactable);
        }

        foreach (var interactable in found)
        {
            if (_current.Add(interactable))
                interactable.SetHighlighted(true);
        }

        _current.RemoveWhere(interactable =>
        {
            if (found.Contains(interactable)) return false;
            interactable.SetHighlighted(false);
            return true;
        });
    }
}
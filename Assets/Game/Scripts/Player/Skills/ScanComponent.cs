using DG.Tweening;
using PixPlays.ElementalVFX;
using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class ScanComponent : MonoBehaviour
{


    private PlayerInputController _inputController;
    [SerializeField] private LayerMask _scanMask;
    [SerializeField] private VFXTester _vfxTester;
    [SerializeField] private Transform _target;
    [SerializeField] private Light _scanLight;
    private Sequence _scanSequence;

    private GuardController _currentGuard;

    private void Awake()
    {
        _inputController = GetComponent<PlayerInputController>();
    }

    // Start is called once before the first execution of Update after the MonoBehaviour is created
    void Start()
    {
        CreateScanSequence();

        _inputController.OnScanPressed += ExpandScanLight;
        _inputController.OnScanReleased += CollapseScanLight;
        // _inputController.OnScanPressed += StartScanning;
        // _inputController.OnScanReleased += StopScanning;
    }

    private void StopScanning()
    {
       
    }

    private void OnDisable()
    {
        _inputController.OnScanPressed -= ExpandScanLight;
        _inputController.OnScanReleased -= CollapseScanLight;
        // _inputController.OnScanPressed -= StartScanning;
        // _inputController.OnScanReleased -= StopScanning;
    }

    private const float scanRadius = 5f;
    private Collider[] _lastHits;

    private void StartScanning()
    {
        _lastHits = Physics.OverlapSphere(transform.position, scanRadius, _scanMask);

        if (_lastHits.Length > 0)
        {
            _currentGuard = _lastHits[0].GetComponent<GuardController>();
            StartCoroutine(CoScanlines());
            _target.transform.position = _lastHits[0].transform.position;
            StartCoroutine(_vfxTester.Coroutine_Spawn());
        }
    }

        
    private IEnumerator CoScanlines()
    {
        while(_currentGuard != null)
        {

            // Example: Update guard detection or show UI

            yield return null;
        }
    }

    private void OnDrawGizmos()
    {
        // Scan radius
        Gizmos.color = Color.green;
        Gizmos.DrawWireSphere(transform.position, scanRadius);

        if (_lastHits == null)
            return;

        foreach (var hit in _lastHits)
        {
            if (hit == null)
                continue;

            // Line to detected object
            Gizmos.color = Color.yellow;
            Gizmos.DrawLine(transform.position, hit.bounds.center);

            // Mark detected object
            Gizmos.color = Color.red;
            Gizmos.DrawWireSphere(hit.bounds.center, 0.2f);
        }
    }


    private void CreateScanSequence()
    {
        _scanLight.range = 0f;
        _scanLight.intensity = 1f;

        _scanSequence = DOTween.Sequence()

            .Join(DOTween.To(
                () => _scanLight.range,
                x => _scanLight.range = x,
                3f,
                0.5f))
            .SetEase(Ease.OutQuad)
            .Pause()
            .SetAutoKill(false);
    }

    private void ExpandScanLight()
    {
        _scanSequence.PlayForward();
    }

    private void CollapseScanLight()
    {
        _scanSequence.PlayBackwards();
    }
}

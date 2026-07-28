using System.Collections.Generic;
using DG.Tweening;
using UnityEngine;

public class VinePickUp : TrapItemBase
{
    [SerializeField] private List<GameObject> _vines;
    [SerializeField] private float growDuration = 0.4f;
    [SerializeField] private float shakeStrength = 0.15f;
    [SerializeField] private float shakeDuration = 0.3f;

    void Start()
    {

    }

    void Update()
    {

    }

    protected override void OnTrapTriggered(EnemyController enemy)
    {
        foreach (var vine in _vines)
        {
            if (vine == null) continue;

            vine.SetActive(true);
            vine.transform.localScale = Vector3.zero;

            Sequence seq = DOTween.Sequence();
            seq.Append(vine.transform.DOScale(Vector3.one, growDuration).SetEase(Ease.OutBack));
            seq.Append(vine.transform.DOShakePosition(shakeDuration, shakeStrength, 10, 90f));
        }
        effectAudio.Play();
    }
}
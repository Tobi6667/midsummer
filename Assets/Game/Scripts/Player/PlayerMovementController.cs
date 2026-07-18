using DG.Tweening;
using System;
using UnityEngine;

[RequireComponent(typeof(CharacterController))]
public class PlayerMovementController : MonoBehaviour
{
    internal void MoveTo(Transform target, float duration, Action onArrive)
    {
        Tween moveTween = transform.DOMove(target.position, duration).SetEase(Ease.InOutQuad).OnComplete(() =>
        {
            onArrive?.Invoke();
        });

        moveTween.OnUpdate(() =>
        {
            Vector3 direction = (target.position - transform.position).normalized;
            if (direction.sqrMagnitude > 0.001f)
            {
                Quaternion lookRotation = Quaternion.LookRotation(direction);
                transform.rotation = Quaternion.Slerp(transform.rotation, lookRotation, Time.deltaTime * 10f);
            }
        });
    }
}
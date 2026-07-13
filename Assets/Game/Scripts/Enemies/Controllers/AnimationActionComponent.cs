using System;
using System.Collections;
using UnityEngine;

public class AnimationActionComponent : MonoBehaviour
{
    [SerializeField] private Animator _animator;
    [SerializeField] private AnimationClip _placeholderClipA;    // "No" state's clip
    [SerializeField] private AnimationClip _placeholderClipB;    // "No2" state's clip
    [SerializeField] private AnimationClip _placeholderClipLoop; // "LoopAnim" state's clip
    [SerializeField] private float _crossfadeDuration = 0.6f;

    private AnimatorOverrideController _animatorOverrideController;

    static readonly int PlaceholderHashA = Animator.StringToHash("No");
    static readonly int PlaceholderHashB = Animator.StringToHash("No2");

    private Action _onComplete;
    private bool _useA = true;
    private Coroutine _sequenceRoutine;

    private void Awake()
    {
        _animatorOverrideController = new AnimatorOverrideController(_animator.runtimeAnimatorController);
        _animator.runtimeAnimatorController = _animatorOverrideController;
    }

    /// <param name="loopClip">If not null, played sequence, then the animator transitions
    /// into LoopAnim (via its own isLooping condition) using this clip, and stays there
    /// until StopLooping() is called. If null, plays the sequence once and returns to idle.</param>
    public void PlayAnimations(AnimationClip[] clips, Action onComplete, AnimationClip loopClip = null)
    {
        if (_sequenceRoutine != null)
            StopCoroutine(_sequenceRoutine);

        _onComplete = onComplete;
        _animator.SetBool("isActing", true);
        _useA = true;
        _sequenceRoutine = StartCoroutine(PlaySequence(clips, loopClip));
    }

    private IEnumerator PlaySequence(AnimationClip[] clips, AnimationClip loopClip)
    {
        if (clips.Length == 0)
            yield break;

        // pre-apply the first clip's override before anything plays
        ApplyOverride(_useA, clips[0]);
        _animator.Update(0f);

        for (int i = 0; i < clips.Length; i++)
        {
            var clip = clips[i];
            int targetHash = _useA ? PlaceholderHashA : PlaceholderHashB;

            if (i == 0)
                _animator.Play(targetHash, 0, 0f); // first clip: no previous state to blend from
            else
                _animator.CrossFade(targetHash, _crossfadeDuration, 0, 0.5f);

            _useA = !_useA;

            // pre-apply the NEXT clip into the other slot right away, so it has the
            // whole "wait" duration to propagate instead of being set the instant we crossfade to it
            if (i + 1 < clips.Length)
                ApplyOverride(_useA, clips[i + 1]);

            yield return null;
            // wait for clip length minus the overlap so the next crossfade kicks in on time
            float wait = Mathf.Max(0f, clip.length - (i < clips.Length - 1 ? _crossfadeDuration : 0f));

            if (loopClip != null && i == clips.Length - 1)
            {
                _animatorOverrideController[_placeholderClipLoop] = loopClip;
                _animator.Update(0f);
                // hand off to the animator's own No/No2 -> LoopAnim transition
                _animator.SetBool("isLooping", true);
            }

            yield return new WaitForSeconds(wait);
        }

        if (loopClip == null)
        {
            _onComplete?.Invoke();
            _animator.SetBool("isActing", false);
            _animator.SetBool("isLooping", false);
        }

        _sequenceRoutine = null;
    }

    private void ApplyOverride(bool useA, AnimationClip clip)
    {
        AnimationClip placeholder = useA ? _placeholderClipA : _placeholderClipB;
        _animatorOverrideController[placeholder] = clip;
        _animator.Update(0f);
    }

    /// Call this to break out of LoopAnim and return to idle.
    public void StopLooping()
    {
        if (_sequenceRoutine != null)
        {
            StopCoroutine(_sequenceRoutine);
            _sequenceRoutine = null;
        }

        _animator.SetBool("isActing", false);
        _animator.SetBool("isLooping", false);
        _onComplete?.Invoke();
    }
}
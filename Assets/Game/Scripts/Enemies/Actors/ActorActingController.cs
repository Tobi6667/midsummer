using System;
using System.Collections;
using System.Collections.Generic;
using Unity.VisualScripting;
using UnityEngine;

public class ActorActingController : MonoBehaviour
{
    [SerializeField] private List<ActorActions> actions;
    private NPCInteractionComponent interactionComponent;

    [SerializeField] private AnimationActionComponent actionComponent;

    private Coroutine _actingCoroutine;

    private bool _isWaiting = false;

    private void Start()
    {
        StoryEventBus.Subscribe<WaitForTurnEvent>(OnTurn);
        interactionComponent = GetComponent<NPCInteractionComponent>();
    }

    private void OnTurn(WaitForTurnEvent @event)
    {
        _isWaiting = false;
    }

    internal void StartActing()
    {
        StopActing(); // guard against overlapping runs
        _actingCoroutine = StartCoroutine(PlayAct());
    }

    internal void StopActing()
    {
        if (_actingCoroutine != null)
        {
            StopCoroutine(_actingCoroutine);
            _actingCoroutine = null;
        }
    }

    private IEnumerator PlayAct()
    {
        var actAction = interactionComponent.GetSelection();
        if (actAction != null)
        {
            actions[actAction.interactionToReplace].animation = actAction.animationClips;
        }

        foreach (ActorActions actorAction in actions)
        {
            yield return ExecuteAction(actorAction);
        }

        _actingCoroutine = null; // finished naturally
    }

    private IEnumerator ExecuteAction(ActorActions actorAction)
    {
        Debug.Log(actorAction.action);

        if (actorAction.needsItem && !interactionComponent.HasItem())
        {
            yield break;
        }

        switch (actorAction.action)
        {
            case EActorAction.MoveTo:
                yield return MoveTo(actorAction.target.position);
                break;

            case EActorAction.PlayAnimation:
                        yield return PlayAnimation(actorAction.animation);
                break;

            case EActorAction.Speak:
                yield return Speak(actorAction);
                break;

            case EActorAction.Wait:
                yield return new WaitForSeconds(actorAction.waitTime);
                break;
            case EActorAction.WaitForTurn:
                yield return WaitForTurn();
                break;
        }
        if(actorAction.sendEvent)
        {
            StoryEventBus.Publish(new WaitForTurnEvent());
        }
    }

    private IEnumerator MoveTo(Vector3 target)
    {
        float speed = 2f;

        while (Vector3.Distance(transform.position, target) > 0.1f)
        {
            transform.position = Vector3.MoveTowards(transform.position, target, speed * Time.deltaTime);
            yield return null;
        }

        transform.position = target;
    }
    
    private IEnumerator PlayAnimation(AnimationClip[] clip)
    {
        bool done = false;
        actionComponent.PlayAnimations(clip, () => { done = true; }, null);

        while (done == false)
        {
            yield return null;
        }
    }


    private void OnDisable()
    {
        StoryEventBus.Unsubscribe<WaitForTurnEvent>(OnTurn);

    }
    private IEnumerator Speak(ActorActions action)
    {
        if (action.animation != null && action.animation.Length > 0)
        {
            actionComponent.PlayAnimations(action.animation, null, action.animation[0]);
        }

        if (action.voice == null)
            yield break;

        AudioManager.Instance.PlayVoiceLine(action.voice);
        Debug.Log(action.voice.name);

        yield return new WaitForSeconds(action.voice.length);
    }

    private IEnumerator WaitForTurn()
    {
        _isWaiting = true;
        while(_isWaiting)
        {
            yield return null;
        }

        
    }

}
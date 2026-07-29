using System;
using UnityEngine;
using UnityEngine.Playables;

public  class ActManager : MonoBehaviour
{
    public static ActManager Instance;

    [SerializeField] private ActorController _bottom;
    [SerializeField] private ActorController _wall;


    [SerializeField] private Transform _curtainBlockade;

    [SerializeField] private PlayableDirector _actTimeline;
    [SerializeField] private PlayableDirector _actSolvedTimeline;

    [SerializeField] private AudioSource _audio;

    private void Awake()
    {
        Instance = this;
    }

    private void OnEnable()
    {
        _actTimeline.stopped += OnTimelineFinished;
    }

    private void OnTimelineFinished(PlayableDirector director)
    {
        if(_bottom.InteractComponent.HasItem() &&  _wall.InteractComponent.HasItem())
        {
            _actSolvedTimeline.Play();
        }
        else
        {
            _audio.Play();
        }
    }

    private void OnDisable()
    {
        _actTimeline.stopped -= OnTimelineFinished;
    }


    public void PlayAct()
    {
        _actTimeline.Play();

    }

    public void StopAct()
    {

    }




}

using UnityEngine;
using UnityEngine.Playables;

public  class ActManager : MonoBehaviour
{
    public static ActManager Instance;

    [SerializeField] private ActPlayData _actData;
    [SerializeField] private Transform _curtainBlockade;

    [SerializeField] private PlayableDirector _actTimeline;
    [SerializeField] private PlayableDirector _actSolvedTimeline;

    private void Awake()
    {
        Instance = this;
    }

    private void Start()
    {
        StoryEventBus.Subscribe<RemoveCurtainEvent>(RemoveCurtain);

        
    }

    private void RemoveCurtain(RemoveCurtainEvent @event)
    {
        Debug.Log("SOÖVED");
         _curtainBlockade.gameObject.SetActive(false);

        StopAct();
        _actTimeline.Stop();
        _actSolvedTimeline.Play();

    }

    public void PlayAct()
    {
        _actTimeline.Play();
        Debug.Log("start actor");
        foreach (var actor in _actData._actors)
        {
            actor.StartActing();
        }
    }

    public void StopAct()
    {

        Debug.Log("STOP THE SHIT");
        foreach(var actor in _actData._actors)
        {
            actor.StopAct();
        }
    }

    private void OnDisable()
    {
        StoryEventBus.Unsubscribe<RemoveCurtainEvent>(RemoveCurtain);

    }


}

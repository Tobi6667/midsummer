using UnityEngine;

public  class ActManager : MonoBehaviour
{
    public static ActManager Instance;

    [SerializeField] private ActPlayData _actData;
    [SerializeField] private Transform _curtainBlockade;

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
        _curtainBlockade.gameObject.SetActive(false);
    }

    public void PlayAct()
    {
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

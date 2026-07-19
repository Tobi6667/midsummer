using System;
using System.Collections.Generic;
using Unity.VisualScripting;
using UnityEngine;
using UnityEngine.UIElements;

public class NPCInteractionComponent : MonoBehaviour
{
    private SoInteractionAction _selectedAction;
    [SerializeField] private EnemyBase _spawnChar;
    [SerializeField] private Transform _spawnPos;
    private Action _onFinished;
    //[SerializeField] private List<SoInteractionAction> _interactions;
    private int _actionIndexer = 0;

    public SoInteractionAction AssignedAction => _selectedAction;

    [SerializeField] private List<InteractData> _interactDataList;
    internal void TriggerInteraction(Action onFinished)
    {
        _onFinished = onFinished;
        var dataInter = _interactDataList[_actionIndexer];
        Debug.Log("index: " + _actionIndexer);
        switch (_interactDataList[_actionIndexer].interactionType)
        {
            case EInteractionType.MoveForward:
                //ExecuteInteraction(_interactions[_actionIndex]);
                if (dataInter.actions[0].needsItem)
                {
                    if (InventoryManagerNEW.Instance.HasItem(dataInter.actions[0].inventoryItem))
                    {
                        CompleteInteraction(dataInter);
                    }
                }
                else
                {
                    CompleteInteraction(dataInter);
                }
                _onFinished?.Invoke();
                break;

            case EInteractionType.PlayText:
                UIManager.Instance.ShowDialog(dataInter.dialogText, () =>
                {
                    _actionIndexer++;
                    CompleteInteraction(dataInter);
                    _onFinished?.Invoke();
                });
                break;
        }
    }

    private void CompleteInteraction(InteractData data)
    {
        switch (data.completedEvent)
        {
            case EStoryEvent.GuardTalked:

                StoryEventBus.Publish(
                    new GuardTalkedEvent(this, _spawnChar, _spawnPos.position)
                );

                break;


            case EStoryEvent.Act1Finished:

                StoryEventBus.Publish(
                    new FinishTutorialEvent()
                );

                break;
        }
    }


    internal void SelectInterAction(Action onFinish)
    {

        UIManager.Instance.OpenSelection(_interactDataList[_actionIndexer].actions, (interAct) =>
            {

                _selectedAction = interAct;
                onFinish?.Invoke();
            });
        
    }



    private void ExecuteInteraction(SoInteractionAction interactData)
    {
        if(interactData.needsItem == false)
        {
        }
    }


    // Start is called once before the first execution of Update after the MonoBehaviour is created
    void Start()
    {
        
    }

    // Update is called once per frame
    void Update()
    {
        
    }
}

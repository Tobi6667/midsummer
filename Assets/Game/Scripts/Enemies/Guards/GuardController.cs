using UnityEngine;

public class GuardController : MonoBehaviour, IInteractable
{
    
    private NPCInteractionComponent _interactComponent;

    public void Interact()
    {
        Debug.Log("selectooooor");
        _interactComponent.SelectInterAction();
    }

    // Start is called once before the first execution of Update after the MonoBehaviour is created
    void Start()
    {
        _interactComponent = GetComponent<NPCInteractionComponent>();
    }

    // Update is called once per frame
    void Update()
    {
        
    }
}

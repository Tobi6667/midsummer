using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UIElements;

public class NPCInteractionComponent : MonoBehaviour
{


    [SerializeField] private List<SoInteractionAction> _interactions;

    internal void SelectInterAction()
    {

            UIManager.Instance.OpenSelection(_interactions, (interAct) =>
            {
                Debug.Log("interaaaa " + interAct);
            });
        
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

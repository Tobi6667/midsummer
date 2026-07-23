using UnityEngine;
using UnityEngine.UIElements;
using System.Collections.Generic;


public class PasswordDoor : MonoBehaviour
{
    [SerializeField] private  UIDocument _uiPW;
    [SerializeField] private List<SoPasswordItem> _allPwItems;

    private VisualElement _rootElement;
    private VisualElement _slotPanel;

    private List<SoPasswordItem> _pwList;
    

    // Start is called once before the first execution of Update after the MonoBehaviour is created
    void Start()
    {
        _rootElement = _uiPW.rootVisualElement;
        _slotPanel = _rootElement.Q<VisualElement>("slots-panel");
        for(int i = 0; i<4; i++)
        {
            CreateSlot();
        }

    }

    // Update is called once per frame
    void Update()
    {
        
    }


    private void CreateSlot()
    {
        VisualElement slot = new VisualElement();
        Button btnUp = new Button();
        Button btnDown = new Button();
        Image icon = new Image();

        slot.AddToClassList("pw-item");
        icon.AddToClassList("pw-icon");

        slot.Add(btnUp);
        slot.Add(icon);
        icon.image = _allPwItems[0].Icon.texture;
        slot.Add(btnDown);
        _slotPanel.Add(slot);
    }
}

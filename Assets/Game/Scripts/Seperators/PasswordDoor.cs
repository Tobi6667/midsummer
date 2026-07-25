using UnityEngine;
using UnityEngine.UIElements;
using System.Collections.Generic;
using System;


public class PasswordDoor : MonoBehaviour, IInteractable
{
    [SerializeField] private  UIDocument _uiPW;
    [SerializeField] private List<SoPasswordItem> _allPwItems;

    [SerializeField] private List<int> _password;

    private VisualElement _rootElement;
    private VisualElement _slotPanel;

    private Button _submitBtn;

    private List<SoPasswordItem> _pwList;
    private List<int> _selectedIndices = new();

    private bool _pwCorrect = false;

    // Start is called once before the first execution of Update after the MonoBehaviour is created
    void Start()
    {
        _rootElement = _uiPW.rootVisualElement;
        _slotPanel = _rootElement.Q<VisualElement>("slots-panel");
        _submitBtn = _rootElement.Q<Button>("submit-button");
        _submitBtn.clicked += () => SubmitPassword();
        _rootElement.style.display = DisplayStyle.None;
        for(int i = 0; i<4; i++)
        {
            _selectedIndices.Add(0);
            CreateSlot(i);
        }

    }

    // Update is called once per frame
    void Update()
    {
        
    }

    private void CreateSlot(int slotIndex)
    {
        VisualElement slot = new VisualElement();
        Button btnUp = new Button();
        Button btnDown = new Button();
        Image icon = new Image();

        slot.AddToClassList("pw-item");
        icon.AddToClassList("pw-icon");

    btnUp.clicked += () => ChangeItem(slotIndex, 1, icon);
    btnDown.clicked += () => ChangeItem(slotIndex, -1, icon);

        slot.Add(btnUp);
        slot.Add(icon);
        icon.image = _allPwItems[0].Icon.texture;
        slot.Add(btnDown);
        _slotPanel.Add(slot);
    }


    private void ChangeItem(int slotIndex, int direction, Image icon)
{

    Debug.Log("change image");
    _selectedIndices[slotIndex] += direction;

    if (_selectedIndices[slotIndex] >= _allPwItems.Count)
        _selectedIndices[slotIndex] = 0;

    if (_selectedIndices[slotIndex] < 0)
        _selectedIndices[slotIndex] = _allPwItems.Count - 1;

    icon.image = _allPwItems[_selectedIndices[slotIndex]].Icon.texture;

    Debug.Log($"Changed slot {slotIndex}");
}

    public void Interact(Action onFinished)
    {
        _rootElement.style.display = DisplayStyle.Flex;
        Debug.Log("interact wall");
    }

    private void SubmitPassword()
    {
        _pwCorrect = true;


            for (int i = 0; i < _password.Count; i++)
            {
                if (_password[i] != _selectedIndices[i])
                {
                    _pwCorrect = false;
                    break;
                }
            }
        

        if (_pwCorrect)
        {
            Debug.Log("Correct password!");

            // Open the door here
            // GetComponent<Door>().Open();

            _rootElement.style.display = DisplayStyle.None;
        }
        else
        {
            Debug.Log("Wrong password!");
            _rootElement.style.display = DisplayStyle.None;

            // Optional: play error sound or shake UI
        }
    }
}

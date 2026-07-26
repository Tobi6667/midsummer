using DG.Tweening;
using System;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UIElements;


public class PasswordDoor : MonoBehaviour, IInteractable
{
    [SerializeField] private UIDocument _uiPW;
    [SerializeField] private List<SoPasswordItem> _allPwItems;

    [SerializeField] private List<int> _password;


    [SerializeField] private Transform _doorLeft;
    [SerializeField] private Transform _doorRight;

    private VisualElement _rootElement;
    private VisualElement _slotPanel;

    private Button _submitBtn;
    private Label _statusLabel;

    private List<SoPasswordItem> _pwList;
    private List<int> _selectedIndices = new();
    private List<Label> _slotNameLabels = new();


    private Action _onFinishInteract;
    private bool _pwCorrect = false;

    // Start is called once before the first execution of Update after the MonoBehaviour is created
    void Start()
    {
        _rootElement = _uiPW.rootVisualElement;
        _slotPanel = _rootElement.Q<VisualElement>("slots-panel");
        _submitBtn = _rootElement.Q<Button>("submit-button");
        _statusLabel = _rootElement.Q<Label>("pw-status");
        _submitBtn.clicked += () => SubmitPassword();
        _rootElement.style.display = DisplayStyle.None;

        for (int i = 0; i < 4; i++)
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
        slot.AddToClassList("pw-item");

        Label slotLabel = new Label($"Slot {slotIndex + 1}");
        slotLabel.AddToClassList("pw-slot-label");

        Button btnUp = new Button { text = "\u25B2" }; // ▲
        btnUp.AddToClassList("pw-arrow-btn");

        Image icon = new Image();
        icon.AddToClassList("pw-icon-frame");

        Button btnDown = new Button { text = "\u25BC" }; // ▼
        btnDown.AddToClassList("pw-arrow-btn");

        Label itemNameLabel = new Label();
        itemNameLabel.AddToClassList("pw-slot-label");

        btnUp.clicked += () => ChangeItem(slotIndex, 1, icon, itemNameLabel);
        btnDown.clicked += () => ChangeItem(slotIndex, -1, icon, itemNameLabel);

        slot.Add(slotLabel);
        slot.Add(btnUp);
        slot.Add(icon);
        slot.Add(btnDown);
        slot.Add(itemNameLabel);

        icon.image = _allPwItems[0].Icon.texture;
        itemNameLabel.text = _allPwItems[0].name;
        _slotNameLabels.Add(itemNameLabel);

        _slotPanel.Add(slot);
    }


    private void ChangeItem(int slotIndex, int direction, Image icon, Label itemNameLabel)
    {
        _selectedIndices[slotIndex] += direction;

        if (_selectedIndices[slotIndex] >= _allPwItems.Count)
            _selectedIndices[slotIndex] = 0;

        if (_selectedIndices[slotIndex] < 0)
            _selectedIndices[slotIndex] = _allPwItems.Count - 1;

        var selected = _allPwItems[_selectedIndices[slotIndex]];
        icon.image = selected.Icon.texture;
        itemNameLabel.text = selected.name;
    }

    public void Interact(Action onFinished)
    {
        _statusLabel.style.display = DisplayStyle.None;
        _rootElement.style.display = DisplayStyle.Flex;
        _onFinishInteract = onFinished;
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
            OpenDoor();
            _rootElement.style.display = DisplayStyle.None;
        }
        else
        {
            Debug.Log("Wrong password!");
            _statusLabel.text = "Wrong password.";
            _statusLabel.style.display = DisplayStyle.Flex;

            // Optional: play error sound or shake UI
        }
        _onFinishInteract?.Invoke();
    }


    private void OpenDoor()
    {
        float openAngleLeft = 80f;
        float openAngleRight = -80f;
        float duration = 1.2f;

        _doorLeft
            .DOLocalRotate(new Vector3(0, openAngleLeft, 0), duration)
            .SetEase(Ease.InOutSine);

        _doorRight
            .DOLocalRotate(new Vector3(0, openAngleRight, 0), duration)
            .SetEase(Ease.InOutSine);
    }
}
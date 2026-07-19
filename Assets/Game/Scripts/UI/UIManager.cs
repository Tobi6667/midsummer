using System;
using System.Collections.Generic;
using Tripolygon.UModelerX.Runtime;
using UnityEngine;
using UnityEngine.UIElements;

public class UIManager : MonoBehaviour
{
    public static UIManager Instance;

    [SerializeField] private UIDocument _selectDocument;
    [SerializeField] private VisualTreeAsset _selectPrefabBtn;


    [SerializeField] private UIDocument _uiDocument;
    [SerializeField] private VisualTreeAsset _inventoryItemTemplate;

   // [SerializeField] private List<SoInventoryItem> _inventoryItems;

    private VisualElement _rootElement;
    private VisualElement _inventoryPanel;

    private VisualElement _dialogPanel;
    private Button _closeBtn;

    private VisualElement _rootSelectElement;
    private VisualElement _selectionPanel;
    private Label _dialogLabel;

    private ProgressBar _detectionBar;

    private Action _onclosed;
    private void Awake()
    {
        Instance = this;
        _rootElement = _uiDocument.rootVisualElement;
        _inventoryPanel = _rootElement.Q<VisualElement>("inventory-panel");

        _rootSelectElement = _selectDocument.rootVisualElement;
        _selectionPanel = _rootSelectElement.Q<VisualElement>("select");


        _detectionBar = _rootElement.Q<ProgressBar>("detection-bar");
        _dialogPanel = _rootElement.Q<VisualElement>("dialog-panel");
        _dialogLabel = _dialogPanel.Q<Label>("dialog-label");
        _closeBtn = _dialogPanel.Q<Button>("close-btn");

    }



    public void AddInventoryItem(SoInventoryItem item, Action<SoInventoryItem> onSelected)
    {
        var slotElement = _inventoryItemTemplate.Instantiate();
        slotElement.userData = item;

        slotElement.RegisterCallback<ClickEvent>(evt => OnItemClicked(evt, onSelected));
        _inventoryPanel.Add(slotElement);
    }

    private void OnCloseClicked()
    {
        Debug.Log("click CLOOOSE");
        _onclosed?.Invoke();
    }

    private void OnItemClicked(ClickEvent evt, Action<SoInventoryItem> onSelected)
    {
        var clickedElement = evt.currentTarget as VisualElement;
        var so = clickedElement.userData as SoInventoryItem;

        if (so == null) return;

        Debug.Log($"Clicked: {so.name}");
        onSelected?.Invoke(so);
        // so.worldPrefab, so.icon, etc. all accessible here
    }


    public void OpenSelection(List<SoInteractionAction> interactions, Action<SoInteractionAction> onSelectedInter )
    {
        foreach (var action in interactions)
        {
            var slotElement = _selectPrefabBtn.Instantiate();
            slotElement.userData = action;

            slotElement.RegisterCallback<ClickEvent>(evt => OnActionClicked(evt, onSelectedInter));

            _inventoryPanel.Add(slotElement);
        }
    }


    public void ShowDialog(string textValue, Action onClose)
    {
        _dialogLabel.text = textValue;
        _onclosed = onClose;
        _closeBtn.RegisterCallback<ClickEvent>(evt => OnCloseClicked());

    }


    private void OnActionClicked(ClickEvent evt, Action<SoInteractionAction> onSelectedInter)
    {
        var clicked = evt.currentTarget as VisualElement;
        var so = clicked.userData as SoInteractionAction;

        if (so == null) return;
        onSelectedInter?.Invoke(so); 
    }

    public void UpdateDetectionBar(float _value)
    {
        _detectionBar.value = _value;
    }
}

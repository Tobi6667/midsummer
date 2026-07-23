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
    private VisualElement _inventoryContainer;

    private VisualElement _dialogPanel;
    private Button _closeBtn;

    private VisualElement _rootSelectElement;
    private VisualElement _selectionPanel;
    private Label _dialogLabel;

    private ProgressBar _detectionBar;

    private Action _onclosed;
private List<VisualElement> _inventorySlots = new();


    private void Awake()
    {
        Instance = this;
        _rootElement = _uiDocument.rootVisualElement;
        _inventoryPanel = _rootElement.Q<VisualElement>("inventory-panel");
        _inventoryContainer = _inventoryPanel.Q<VisualElement>("inventory-container");

        _rootSelectElement = _selectDocument.rootVisualElement;
        _selectionPanel = _rootSelectElement.Q<VisualElement>("select-container");


        _detectionBar = _rootElement.Q<ProgressBar>("detection-bar");
        _dialogPanel = _rootElement.Q<VisualElement>("dialog-panel");
        _dialogLabel = _dialogPanel.Q<Label>("dialog-label");
        _closeBtn = _dialogPanel.Q<Button>("close-btn");



    }



public void RefreshInventory(List<InventorySlotData> items)
{
    for (int i = 0; i < _inventorySlots.Count; i++)
    {
        if (i < items.Count)
        {
            UpdateInventorySlot(i, items[i]);
        }
        else
        {
            ClearInventorySlot(i);
        }
    }
}

private void Start()
{
    for (int i = 0; i < 4; i++)
    {
        var slot = new VisualElement();
        slot.AddToClassList("inventory-item");

        Image icon = new Image();
        icon.AddToClassList("inventory-icon");

        Label amount = new Label();
        amount.AddToClassList("inventory-label");
        amount.text = "0";

        slot.Add(icon);
        slot.Add(amount);

        _inventorySlots.Add(slot);
        _inventoryContainer.Add(slot);
    }
}


public void ClearInventorySlot(int index)
{
    VisualElement slot = _inventorySlots[index];

    slot.Q<Image>().image = null;
    slot.Q<Label>().text = "0";
}


public void UpdateInventorySlot(int index, InventorySlotData data)
{
    VisualElement slot = _inventorySlots[index];

    slot.Q<Image>().image = data.item.icon.texture;

    slot.Q<Label>().text = data.amount.ToString();
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

            _selectionPanel.Add(slotElement);
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
        _selectionPanel.style.display = DisplayStyle.None;
        
    }

    public void UpdateDetectionBar(float _value)
    {
        _detectionBar.value = _value;
    }


    public void AddInventoryItem(InventorySlotData data, int index)
{
    VisualElement slot = _inventorySlots[index];

    slot.Q<Image>().image = data.item.icon.texture;
    slot.Q<Label>().text = data.amount.ToString();
}
}

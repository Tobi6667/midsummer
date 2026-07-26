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
    private VisualElement _abilityHotbar;

    private Button _closeBtn;

    private VisualElement _rootSelectElement;
    private VisualElement _selectionPanel;


    private ProgressBar _detectionBar;

    private Action _onclosed;

    // One entry per slot (1-4), holding direct refs to that slot's icon + count label
    // so we never have to guess which Label/Image belongs to which slot.
    private readonly List<Image> _inventoryIcons = new();
    private readonly List<Label> _inventoryCounts = new();


    private void Awake()
    {
        Instance = this;
        _rootElement = _uiDocument.rootVisualElement;
        _abilityHotbar = _rootElement.Q<VisualElement>("ability-hotbar");

        _rootSelectElement = _selectDocument.rootVisualElement;
        _selectionPanel = _rootSelectElement.Q<VisualElement>("select-container");

        _detectionBar = _rootElement.Q<ProgressBar>("detection-bar");

        for (int i = 1; i <= 4; i++)
        {
            _inventoryIcons.Add(_rootElement.Q<Image>($"inventory-slot-{i}-icon"));
            _inventoryCounts.Add(_rootElement.Q<Label>($"inventory-slot-{i}-count"));
        }
    }


    public void RefreshInventory(List<InventorySlotData> items)
    {
        for (int i = 0; i < _inventoryIcons.Count; i++)
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


    public void ClearInventorySlot(int index)
    {
        _inventoryIcons[index].image = null;
        _inventoryCounts[index].text = "";
    }


    public void UpdateInventorySlot(int index, InventorySlotData data)
    {
        _inventoryIcons[index].image = data.item.icon.texture;
        _inventoryCounts[index].text = data.amount > 1 ? $"x{data.amount}" : "";
    }


    public void AddInventoryItem(InventorySlotData data, int index)
    {
        UpdateInventorySlot(index, data);
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


    public void OpenSelection(List<SoInteractionAction> interactions, Action<SoInteractionAction> onSelectedInter)
    {
        _selectionPanel.Clear();
        _selectionPanel.style.display = DisplayStyle.Flex;
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
}
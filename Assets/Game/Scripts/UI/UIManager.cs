using System;
using System.Collections.Generic;
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

    private VisualElement _rootSelectElement;
    private VisualElement _selectionPanel;

    private void Awake()
    {
        Instance = this;
        _rootElement = _uiDocument.rootVisualElement;
        _inventoryPanel = _rootElement.Q<VisualElement>("inventory-panel");

        _rootSelectElement = _selectDocument.rootVisualElement;
        _selectionPanel = _rootSelectElement.Q<VisualElement>("select");

    }



    public void AddInventoryItem(SoInventoryItem item, Action<SoInventoryItem> onSelected)
    {
        var slotElement = _inventoryItemTemplate.Instantiate();
        slotElement.userData = item;

        slotElement.RegisterCallback<ClickEvent>(evt => OnItemClicked(evt, onSelected));

        _inventoryPanel.Add(slotElement);
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

    private void OnActionClicked(ClickEvent evt, Action<SoInteractionAction> onSelectedInter)
    {
        var clicked = evt.currentTarget as VisualElement;
        var so = clicked.userData as SoInteractionAction;

        if (so == null) return;
        onSelectedInter?.Invoke(so);
    }
}

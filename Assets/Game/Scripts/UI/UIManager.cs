using System;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UIElements;

public class UIManager : MonoBehaviour
{
    public static UIManager Instance;
    [SerializeField] private UIDocument _uiDocument;
    [SerializeField] private VisualTreeAsset _inventoryItemTemplate;
   // [SerializeField] private List<SoInventoryItem> _inventoryItems;

    private VisualElement _rootElement;
    private VisualElement _inventoryPanel;


    private void Awake()
    {
        Instance = this;
        _rootElement = _uiDocument.rootVisualElement;
        _inventoryPanel = _rootElement.Q<VisualElement>("inventory-panel");
    }

    // Start is called once before the first execution of Update after the MonoBehaviour is created
    void Start()
    {


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

    // Update is called once per frame
    void Update()
    {
        
    }
}

using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.EventSystems;
using UnityEngine.UI;
using System;
using System.Xml.Serialization;
using System.IO;
using UnityEngine.InputSystem;

public class InventoryManager : MonoBehaviour
{
    static InventoryManager instance;

    public GameObject slotPrefab;
    public GameObject iconPrefab;

    private GameObject hoverObject;

    public GameObject dropItem;
    public GameObject trapItem;
    public GameObject toolObject;

    public Text sizeTextObject;
    public Text visualTextObject;

    public Canvas canvas;

    private Slot from, to;
    private GameObject clicked;

    public Text stackText;

    private int splitAmount;
    private int maxStackCount;

    private Slot movingSlot;

    public EventSystem eventSystem;
    public GameObject selectStackSize;

    ItemContainer itemContainer = new ItemContainer();

    public GameObject itemObject;

    public static InventoryManager Instance
    {
        get
        {
            if (instance == null)
            {
                instance = FindObjectOfType<InventoryManager>();
            }

            return instance;
        }
    }

    public Slot From
    {
        get { return from; }
        set { from = value; }
    }

    public Slot To
    {
        get { return to; }
        set { to = value; }
    }

    public GameObject Clicked
    {
        get { return clicked; }
        set { clicked = value; }
    }

    public int SplitAmount
    {
        get { return splitAmount; }
        set { splitAmount = value; }
    }

    public Slot MovingSlot
    {
        get { return movingSlot; }
        set { movingSlot = value; }
    }

    public GameObject HoverObject
    {
        get { return hoverObject; }
        set { hoverObject = value; }
    }

    public int MaxStackCount
    {
        get { return maxStackCount; }
        set { maxStackCount = value; }
    }

    public ItemContainer ItemContainer
    {
        get { return itemContainer; }
        set { itemContainer = value; }
    }

    public void Start()
    {
        Type[] itemTypes =
        {
            typeof(Equipment),
            typeof(Weapon),
            typeof(Consumable)
        };

        XmlSerializer serializer = new XmlSerializer(typeof(ItemContainer), itemTypes);

        TextReader textReader = new StreamReader(Application.streamingAssetsPath + "/items.xml");
        ItemContainer = (ItemContainer)serializer.Deserialize(textReader);
        textReader.Close();
    }

    public void SetStackInfo(int maxStackCount)
    {
        selectStackSize.SetActive(true);
        toolObject.SetActive(false);

        SplitAmount = 0;
        this.MaxStackCount = maxStackCount;

        stackText.text = SplitAmount.ToString();
    }

    public void Save()
    {
        GameObject[] inventories = GameObject.FindGameObjectsWithTag("Inventory");

        foreach (GameObject inventory in inventories)
        {
            inventory.GetComponent<Inventory>().SaveInventory();
        }
    }

    public void Load()
    {
        GameObject[] inventories = GameObject.FindGameObjectsWithTag("Inventory");

        foreach (GameObject inventory in inventories)
        {
            inventory.GetComponent<Inventory>().LoadInventory();
        }
    }
}
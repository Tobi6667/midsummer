using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class CharacterPanel : Inventory {
    public Slot[] equipmentSlots;
    static CharacterPanel instance;

    public static CharacterPanel Instance
    {
        get
        {
            if (instance == null)
            {
                instance = GameObject.FindObjectOfType<CharacterPanel>();
            }
            return CharacterPanel.instance;
        }
    }
    public Slot WeaponSlot
    { get { return equipmentSlots[9]; }
            }
    public Slot OffHandSlot
    {
        get { return equipmentSlots[10]; }
    }

    // Use this for initialization
    private void Awake()
    {
        equipmentSlots = transform.GetComponentsInChildren<Slot>();


    }
    void Start ()
    {
		
	}
	
	// Update is called once per frame
	void Update ()
    {
		
	}
    public void EquipItem(Slot slot, ItemScript item)
    {
        if (item.Item.ItemType == ItemType.MainHand || item.Item.ItemType == ItemType.TwoHanded && OffHandSlot.IsEmpty)
        {
            Slot.SwapItems(slot, WeaponSlot);
        }
       
        else 
        { Slot.SwapItems(slot, Array.Find(equipmentSlots, x => x.canContain == item.Item.ItemType));
        }
    

    }
    public override void CreateLayout()
    {

    }
    //public override void ShowToolTip(GameObject slot)
    //{
    //    Slot tmpSlot = slot.GetComponent<Slot>();
    //    if (slot.GetComponentInParent<Inventory>().IsOpen && !tmpSlot.IsEmpty && InventoryManager.Instance.HoverObject == null && !InventoryManager.Instance.selectStackSize.activeSelf)
    //    {
    //        InventoryManager.Instance.visualTextObject.text = tmpSlot.CurrentItem.GetTooltip();
    //        InventoryManager.Instance.sizeTextObject.text = InventoryManager.Instance.visualTextObject.text;
    //        InventoryManager.Instance.toolObject.SetActive(true);
    //        float xpos = slot.transform.position.x;
    //        float ypos = slot.transform.position.y;
    //        InventoryManager.Instance.toolObject.transform.position = new Vector2(xpos, ypos);
    //    }
    //}
    //public void CalculateStats()
    //{

    //    int _agility = 0;
    //    int _strength = 0;
    //    int _stamina = 0;
    //    int _intellect = 0;
    //    foreach(Slot slot in equipmentSlots)
    //    {
    //        if (!slot.IsEmpty)
    //        {
    //            Equipment e = (Equipment)slot.CurrentItem.Item;
    //            _agility += e.Agility;
    //            _intellect += e.Intellect;
    //            _stamina += e.Stamina;
    //            _strength += e.Strength;
    //         }
           
    //    }
    //    Player.Instance.SetStats(_agility, _strength, _stamina, _intellect);
    //}
    public override void SaveInventory()
    {
        string content = string.Empty;
        for (int i=0;i<equipmentSlots.Length;i++)
        {
            if (!equipmentSlots[i].IsEmpty)
            {
                content += i + "-" + equipmentSlots[i].Items.Peek().Item.ItemName + ";";
            }
        }
        PlayerPrefs.SetString("CharPanel", content);
        PlayerPrefs.Save();

    }
    public override void LoadInventory()
    {
        foreach(Slot slot in equipmentSlots)
        {
            slot.ClearSlot();
        }
        string content = PlayerPrefs.GetString("CharPanel");
        string[] splitContent = content.Split(';');
        for(int i=0;i<splitContent.Length-1;i++)
        {
            string[] splitValues = splitContent[i].Split('-');
            int index = Int32.Parse(splitValues[0]);
            string itemName = splitValues[1];
            GameObject loadedItem = Instantiate(InventoryManager.Instance.itemObject);
            loadedItem.AddComponent<ItemScript>();
            if(index==9 || index==10)
            {
                loadedItem.GetComponent<ItemScript>().Item = InventoryManager.Instance.ItemContainer.Weapons.Find(x => x.ItemName == itemName);
            }
            else
            {
                loadedItem.GetComponent<ItemScript>().Item = InventoryManager.Instance.ItemContainer.Equipment.Find(x => x.ItemName == itemName);

            }
            equipmentSlots[index].AddItem(loadedItem.GetComponent<ItemScript>());
            Destroy(loadedItem);
           // CalculateStats();
        }
    }
}
